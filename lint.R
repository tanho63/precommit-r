#! /usr/local/bin/Rscript

args <- docopt::docopt(
  doc = "
    Apply linter fixes via flir, for usage in precommit docker.
    Usage:
      script [<files>...]
    Options:
      <files> files to lint [default: .]
  "
)

# update repo's flir if outdated
system2(
  "cp",
  args = c(
    "-r",
    "-u",
    "/precommit/flir",
    "/src"
  )
)
# append flir to .Rbuildignore and .dockerignore
if (
  fs::file_exists(".Rbuildignore") &&
    any(grepl("flir", readLines(".Rbuildignore", warn = FALSE)))
) {
  cat("\n\n# flir files\n^flir$\n", file = ".Rbuildignore", append = TRUE)
}
if (
  fs::file_exists(".dockerignore") &&
    any(grepl("flir", readLines(".dockerignore", warn = FALSE)))
) {
  cat("\n\n# flir files\n^flir$\n", file = ".dockerignore", append = TRUE)
}

files <- unlist(args)
if (length(files) > 0) {
  # First try to fix the files automatically
  flir::fix(unlist(args), force = TRUE, verbose = FALSE)
  # Then run lint to check for anything that can't be fixed automatically
  x <- flir::lint(unlist(args), use_cache = FALSE, verbose = FALSE)
  if (nrow(x) > 0) {
    options(rlang_backtrace_on_error = "none")
    # pretty-print linting
    cli::cli_abort(
      paste0(
        format(x$file),
        "#L",
        x$line_start,
        ": ",
        x$message
      ) |>
        setNames(nm = rep("x", nrow(x))),
      call = call("flir::lint(...)")
    )
  }
}
