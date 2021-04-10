library(magrittr)

unlink("out", recursive = TRUE)
dir.create("out", showWarnings = FALSE)

n_main_thread <- 3

## determine cluster type
cl_type <- ifelse(.Platform$OS.type == "unix", "FORK", "PSOCK")
## create cluster
cl <- parallel::makeCluster(n_main_thread, type = cl_type)
## register cluster for plyr
doParallel::registerDoParallel(cl)

test_tbl <- tibble::tibble(id = 1:100,
                           time = 1)

# Set one sleep time high to test if cluster moves on or waits
test_tbl$time[12] <- 100

test_tbl <-
  test_tbl %>%
  # dplyr::sample_frac() %>% # randomize benchmark order
  dplyr::mutate(id2 = seq_len(nrow(.))) %>%
  plyr::ddply(
    "id2",
    .parallel = exists("cl"),
    .progress = ifelse(exists("cl"), "none", "text"),
    function(x) {
      Sys.sleep(x$time)
      x %>% write.csv(paste0("out/", x$id, ".csv"))
    }
  )
