test_that("set_license() provides helpful error for invalid license", {
  # Create a temporary directory for testing
  path <- tempfile("set_license_error")
  dir.create(path)
  defer(unlink(path, recursive = TRUE))
  
  # Create a minimal checklist file
  checklist$new(x = path, language = "en-GB") |>
    write_checklist()
  
  # Create an organization with known licenses
  org <- org_list$new()$add_item(
    org_item$new(
      name = c(`en-GB` = "Test Organization"),
      email = "test@example.org",
      rightsholder = "single",
      funder = "single"
    )
  )
  
  # Get available licenses to verify in error message
  available_licenses <- names(org$get_listed_licenses)
  
  # Ensure we have some licenses to test with
  expect_true(
    length(available_licenses) > 0,
    info = "Organization should have at least one license available"
  )
  
  # Try to set an invalid license and check error message
  error_caught <- tryCatch(
    {
      # Call the internal function with an invalid license
      get_official_license_location(license = "INVALID-LICENSE", org = org)
      FALSE  # If we get here, no error was thrown
    },
    error = function(e) {
      # Check that the error message contains available licenses
      error_msg <- conditionMessage(e)
      
      # Verify error message mentions available licenses
      expect_true(
        grepl("Available licenses:", error_msg),
        info = "Error message should mention 'Available licenses:'"
      )
      
      # Verify error message contains at least some license names
      for (lic in available_licenses) {
        expect_true(
          grepl(lic, error_msg, fixed = TRUE),
          info = sprintf("Error message should contain license '%s'", lic)
        )
      }
      
      TRUE  # Error was caught
    }
  )
  
  expect_true(error_caught, info = "An error should have been thrown")
})
