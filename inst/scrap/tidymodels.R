library(tidymodels)

# ---------------------------------------------------------------------------

set.seed(6735)
all_folds <- vfold_cv(iris, v = 5)

rec <-
  recipe(Species ~ ., data = iris)

spec <-
  parsnip::boost_tree(
    trees = 1000,
    tree_depth = hardhat::tune(),
    min_n = hardhat::tune(),
    loss_reduction = hardhat::tune(),                   
    sample_size = hardhat::tune(), 
    mtry = hardhat::tune(),
    learn_rate = hardhat::tune()                          
  ) |>
  parsnip::set_engine("xgboost")  |>
  parsnip::set_mode("classification")

grid <- dials::grid_latin_hypercube(
  dials::tree_depth(),
  dials::min_n(),
  dials::loss_reduction(),
  sample_size = dials::sample_prop(),
  dials::finalize(dials::mtry(), iris),
  dials::learn_rate(),
  size = 5
) 

wflow <-
  workflows::workflow() |>
  workflows::add_recipe(recipe = rec) |>
  workflows::add_model(spec)

tuned <- tune::tune_grid(
  wflow,
  resamples = all_folds,
  grid = grid,
  control = tune::control_grid(verbose = TRUE)#,
                               #parallel_over = "resamples")
)

tuned2 <- select(tuned, -splits)
att <- attributes(tuned)
for(at in names(att)[names(att) != "names"]) {
  attr(tuned2, at) <- attr(tuned, at)
}

tune::select_by_one_std_err(tuned,  mtry, min_n, tree_depth, learn_rate, loss_reduction, sample_size)

