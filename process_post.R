# Load necessary libraries
library(rmarkdown)
library(fs)

# Define the paths
src_folder <- "_src"
posts_folder <- "_posts"
figures_folder <- "_figures"

# Specify the .qmd file to process
qmd_file <- file.path(src_folder, "professional-post.qmd")

# Extract the base name of the .qmd file (e.g., "professional-post")
qmd_base_name <- path_ext_remove(path_file(qmd_file))

# Render the .qmd file to .md
render(input = qmd_file, output_format = "md_document", output_dir = src_folder)

# Define the .md output filename (use the same base name as .qmd)
md_filename <- paste0(format(Sys.Date(), "%Y-%m-%d"), "-", qmd_base_name, ".md")
md_file_path <- file.path(posts_folder, md_filename)

# Move the rendered .md file to the _posts folder and rename it
rendered_md_path <- file.path(src_folder, paste0(qmd_base_name, ".md"))
file_move(rendered_md_path, md_file_path)

# Read the .md file content for figure processing
md_content <- readLines(md_file_path)

# Extract figure paths from both HTML <img> tags and Markdown-style references
fig_files <- c(
  # Extract src paths from HTML <img> tags
  regmatches(md_content, gregexpr('src="([^"]+)"', md_content)),
  # Extract paths from Markdown-style references
  regmatches(md_content, gregexpr("\\(.*?\\.(png|jpg|jpeg|gif|svg)\\)", md_content))
)

# Flatten the list and clean up the paths
fig_files <- unlist(fig_files)
fig_files <- unique(gsub('src=|"|\\(|\\)', "", fig_files))  # Remove src=, quotes, parentheses

# Move the figure files to the _figures folder
for (fig_file in fig_files) {
  old_path <- fig_file  # The figure path extracted from the HTML or Markdown
  new_path <- file.path(figures_folder, basename(fig_file))  # Target path in _figures
  
  # Check if the figure exists at the specified path and move it
  if (file_exists(old_path)) {
    file_move(old_path, new_path)
  }
}

# Update figure paths in the .md file to point to the root-relative _figures folder
md_content <- gsub(
  'src=".*?/([^/]+\\.[a-zA-Z]+)"',   # Match the src attribute for any nested path
  'src="/_figures/\\1"',             # Replace with a root-relative path to _figures
  md_content
)

# Write the updated content back to the .md file
writeLines(md_content, md_file_path)

# Write the updated content back to the .md file
writeLines(md_content, md_file_path)