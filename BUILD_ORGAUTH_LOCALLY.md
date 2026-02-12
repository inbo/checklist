# How to Build and Push orgauth Package from Your Local Machine

## Problem
The orgauth package folder doesn't exist on your local machine - it was created in the CI environment.

## Solution
Use the provided build script to create the orgauth package from the checklist repository files.

---

## Quick Start

### 1. Clone the checklist repository (if not already done)
```bash
git clone https://github.com/inbo/checklist.git
cd checklist
```

### 2. Run the build script
```bash
./build_orgauth_package.sh ../orgauth
```

This will create the orgauth package in the `../orgauth` directory.

### 3. Push to GitHub
```bash
cd ../orgauth
git remote add origin https://github.com/inbo/orgauth.git
git branch -M main
git push -u origin main
```

---

## Detailed Instructions

### Step 1: Prepare Your Environment

Make sure you have the checklist repository on your local machine:

```bash
# If you don't have it yet, clone it:
git clone https://github.com/inbo/checklist.git
cd checklist

# If you already have it, make sure it's up to date:
cd checklist
git checkout main
git pull
```

### Step 2: Run the Build Script

The `build_orgauth_package.sh` script extracts the necessary files from checklist and creates the orgauth package structure.

**Basic usage** (creates in `../orgauth`):
```bash
./build_orgauth_package.sh
```

**Custom location**:
```bash
./build_orgauth_package.sh /path/to/where/you/want/orgauth
```

**Examples**:
```bash
# Create in parent directory
./build_orgauth_package.sh ../orgauth

# Create in your projects folder
./build_orgauth_package.sh ~/projects/orgauth

# Create in current directory's parent
./build_orgauth_package.sh ../orgauth
```

### What the Script Does

The build script will:
1. ✅ Create the directory structure (R/, man/, tests/, etc.)
2. ✅ Copy R source files from checklist
3. ✅ Create utils.R with validation functions
4. ✅ Update all references from "checklist" to "orgauth"
5. ✅ Create DESCRIPTION, NAMESPACE, README.md, NEWS.md
6. ✅ Copy LICENSE.md and .gitignore
7. ✅ Initialize git repository
8. ✅ Create initial commit

### Step 3: Verify the Package

After the script completes, verify the package structure:

```bash
cd ../orgauth  # or wherever you created it
ls -la

# You should see:
# - R/ directory with 6 R files
# - DESCRIPTION
# - NAMESPACE
# - README.md
# - NEWS.md
# - LICENSE.md
# - .gitignore
# - .Rbuildignore
# - .git/ directory
```

Check git status:
```bash
git status
# Should show: On branch master, nothing to commit, working tree clean

git log --oneline
# Should show: Initial package structure for orgauth
```

### Step 4: Push to GitHub

Now push the package to GitHub:

```bash
# Add the GitHub remote
git remote add origin https://github.com/inbo/orgauth.git

# Rename branch to main (GitHub's default)
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 5: Verify on GitHub

Visit https://github.com/inbo/orgauth and verify:
- ✅ README.md is displayed
- ✅ All files are present
- ✅ License shows GPL-3
- ✅ Commit history shows initial commit

---

## Troubleshooting

### Issue: "Permission denied" when running script

**Solution**: Make the script executable
```bash
chmod +x build_orgauth_package.sh
```

### Issue: "Directory already exists"

The script will ask if you want to overwrite. Type `yes` to proceed.

**Alternative**: Choose a different output directory
```bash
./build_orgauth_package.sh ../orgauth2
```

### Issue: Script fails with sed error on macOS

On macOS, sed works slightly differently. The script handles this automatically, but if you see `.bak` files, they're safe to delete:
```bash
rm -f ../orgauth/R/*.bak
```

### Issue: Authentication required for git push

See the authentication guide in `STEP2_COMPLETE_GUIDE.md` or use:
- Personal Access Token (recommended)
- SSH keys

---

## Alternative: Manual Creation

If the script doesn't work for any reason, you can create the package manually:

### 1. Create directory structure
```bash
mkdir -p ../orgauth/{R,man,tests/testthat,inst/extdata,.github/workflows}
cd ../orgauth
```

### 2. Copy files from checklist
```bash
cp ../checklist/R/org_item_class.R R/
cp ../checklist/R/org_list_class.R R/
cp ../checklist/R/use_author.R R/
cp ../checklist/R/store_authors.R R/
cp ../checklist/R/get_default_org_list.R R/
cp ../checklist/LICENSE.md .
cp ../checklist/.gitignore .
```

### 3. Create utils.R
Create `R/utils.R` with validation functions (see `build_orgauth_package.sh` for content)

### 4. Update references
```bash
# In all R files, replace:
# R_user_dir("checklist" → R_user_dir("orgauth"
sed -i 's/R_user_dir("checklist"/R_user_dir("orgauth"/g' R/*.R
```

### 5. Create package files
Create DESCRIPTION, NAMESPACE, README.md, NEWS.md, .Rbuildignore
(see `build_orgauth_package.sh` for content)

### 6. Initialize git
```bash
git init
git add -A
git commit -m "Initial package structure for orgauth"
```

---

## Package Contents

After building, the orgauth package includes:

### R Files (in R/ directory)
- `org_item_class.R` - R6 class for single organisation (414 lines)
- `org_list_class.R` - R6 class for organisation collections (948 lines)
- `use_author.R` - Author management functions (390 lines)
- `store_authors.R` - Author persistence (204 lines)
- `get_default_org_list.R` - Organisation discovery (113 lines)
- `utils.R` - Validation and helper functions (202 lines)

### Package Files
- `DESCRIPTION` - Package metadata
- `NAMESPACE` - Exported functions and imports
- `README.md` - Package documentation
- `NEWS.md` - Version history
- `LICENSE.md` - GPL-3 license
- `.gitignore` - Git ignore rules
- `.Rbuildignore` - R package build ignore rules

### Total
- 13 files
- ~2,300 lines of R code
- Git repository initialized

---

## After Pushing to GitHub

### Next Steps

1. **Add to inbo R-universe**
   Edit https://github.com/inbo/universe/blob/main/packages.json:
   ```json
   {
     "package": "orgauth",
     "url": "https://github.com/inbo/orgauth"
   }
   ```

2. **Test installation**
   ```r
   remotes::install_github("inbo/orgauth")
   library(orgauth)
   org <- org_item$new(email = "info@inbo.be")
   org$print()
   ```

3. **Update checklist package** (future task)
   - Add orgauth to Imports in DESCRIPTION
   - Update code to use orgauth::org_item, etc.
   - Remove extracted R files
   - Update documentation

---

## Summary

**Problem**: No orgauth folder on local machine  
**Solution**: Use `build_orgauth_package.sh` to create it from checklist files  
**Result**: Complete orgauth package ready to push to GitHub  

**Key Command**:
```bash
./build_orgauth_package.sh ../orgauth
cd ../orgauth
git remote add origin https://github.com/inbo/orgauth.git
git branch -M main
git push -u origin main
```

---

## Questions or Issues?

If you encounter any problems:
1. Check the troubleshooting section above
2. Verify you have git installed: `git --version`
3. Verify you have write access to https://github.com/inbo/orgauth
4. See `STEP2_COMPLETE_GUIDE.md` for detailed git push instructions
