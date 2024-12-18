# Load required libraries
library(stringr)

# Define paths
src_dir <- "_src"
posts_dir <- "_posts"
figures_dir <- "_figures"

# Define the `.md` file and today's date
md_file <- list.files(src_dir, pattern = "\\.md$", full.names = TRUE)
if (length(md_file) == 0) stop("No Markdown (.md) files found in _src!")
today <- Sys.Date()

# Read the content of the Markdown file
content <- readLines(md_file)

# Extract the post title from the file name
file_name <- basename(md_file)
post_title <- str_replace(file_name, "\\.md$", "")

# Create a new file name with today's date and post title
new_file_name <- sprintf("%s-%s.md", today, post_title)
new_file_path <- file.path(posts_dir, new_file_name)

# Standardized YAML metadata
yaml_header <- c(
  "---",
  sprintf("title: \"%s\"", post_title),
  "author: \"Amir Golzan\"",
  sprintf("date: \"%s\"", today),
  "layout: post",
  "categories: [jekyll, tutorial]",
  "---",
  ""
)

# Prepend YAML metadata to the Markdown content
content <- c(yaml_header, content)

# Update figure paths and move them to _figures
content <- str_replace_all(content, "\\!\\[(.*?)\\]\\((.*?)\\)", function(match) {
  # Extract Alt Text and Path
  alt_text <- str_match(match, "\\!\\[(.*?)\\]")[2]
  old_path <- str_match(match, "\\((.*?)\\)")[2]
  
  # Resolve Absolute or Relative Path
  full_old_path <- ifelse(startsWith(old_path, "/"),
                          old_path, # Absolute path
                          file.path(src_dir, old_path)) # Relative path
  
  # Debugging: Print the resolved path
  cat(sprintf("DEBUG: Looking for figure at '%s'\n", full_old_path))
  
  # Ensure the figure is moved to _figures
  figure_name <- basename(full_old_path)
  new_path <- file.path(figures_dir, figure_name)
  if (file.exists(full_old_path)) {
    file.copy(full_old_path, new_path, overwrite = TRUE)
  } else {
    warning(sprintf("Figure not found: %s", full_old_path))
  }
  
  # Return the updated Markdown syntax with the new path
  sprintf("![%s](/_figures/%s)", alt_text, figure_name)
})

# Save the updated Markdown content to the `_posts` directory
writeLines(content, new_file_path)

# Remove the original `.md` file
file.remove(md_file)

cat(sprintf("Processed '%s' to '%s'. Figures moved to '%s'.\n", file_name, new_file_path, figures_dir))