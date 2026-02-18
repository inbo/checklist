# Organisations

## New philosophy

`checklist 0.5.0` had a major change in the way it handles organisation
information. The old `organisation` object was replaced by two new
classes: `org_item` and `org_list`. Another important change is that an
organisation can define minimum rules for the organisation. This set of
rules is stored in a repository called `checklist` in the organisation’s
git organisation.

### Why bother to set an `org_list` object?

[`check_package()`](https://inbo.github.io/checklist/reference/check_package.md)
and
[`check_project()`](https://inbo.github.io/checklist/reference/check_project.md)
use this information to check if the project is compliant with the
organisation’s rules about naming conventions, copyright holder and
funder. This allows the organisation to enforce a consistent set of
rules across all its projects.

## The `org_item` class

The `org_item` class is used to store information about an organisation.
It contains the two mandatory fields: `name` and `email`. The name must
be a named vector using a language code as name. This allows the
organisation name to be used in different languages. The first name will
be used as the default name when no match is available. The email served
a double purpose: 1. Having an organisation email in the metadata allows
users to contact the organisation in case that the individual authors
are not available or do not respond. 2. `checklist` uses the domain of
the email to match other persons to this organisation based on email.

Optionally, you can define the organisations’ [ROR
identifier](https://ror.org/); the website; a link to the logo; if
matching persons must having an [ORCID identifier](https://orcid.org/);
if the projects must list a specific [Zenodo
community](https://zenodo.org/communities#community-info) and what kind
of licenses are allowed for packages, projects and data.

The `org_item` defines the required status of the organisation as a
copyright holder or funder. By default, this is set to `"optional"`,
which means that the organisation is not required to be listed as a
copyright holder or funder but it can be listed as such. `"single"` is
the other side of the spectrum, which means that the organisation must
be listed as a copyright holder or funder and no other organisation can
be listed as such. `"shared"` is a weaker version of `"single"` where
the organisation must be listed as a copyright holder or funder but
other organisations can be listed as such too. Finally,
`"when no other"` means that the organisation must be listed as a
copyright holder or funder when no other organisation is listed as such.

## The `org_list` class

The `org_list` class is used to store a list of `org_item` elements. The
rules of the different `org_item` within a single `org_list` must be
compatible. E.g. if one organisation is set to `"single"` as copyright
holder, then no other organisation can be set to `"single"` or
`"shared"` as copyright holder.

Additionally, it contains the URL of the main organisations git
organisation. The `checklist` repository at that URL is used to store
the minimum rules for the organisation. E.g. when the URL is set to
<https://github.com/inbo>, then we look for the minimum rules at
<https://github.com/inbo/checklist>.

## Using the organisations default `org_list`

We provide a dummy example of an organisations’ `checklist` repository
at <https://gitlab.com/ThierryO/checklist>.

### Setting the default

You can do that interactively with the
[`new_org_list()`](https://inbo.github.io/checklist/reference/new_org_list.md)
function. Or programmatically using the `org_item$new()` constructor.

First you need to create the `org_item` objects that will make up the
default `org_list`. Note that you must provide a link to a markdown file
for the licenses you want to allow. We recommend to include these
markdown files in your organisations’ `checklist` repository.
`checklist` cache the content of these license files locally. And it
include them as a `LICENSE.md` file within the package or project.

``` r

library(checklist)
inbo <- org_item$new(
  name = c(
    "nl-BE" = "Instituut voor Natuur- en Bosonderzoek (INBO)",
    "fr-FR" = "Institut de Recherche sur la Nature et les Forêts (INBO)",
    "en-GB" = "Research Institute for Nature and Forest (INBO)",
    "de-DE" = "Institut für Natur- und Waldforschung (INBO)"
  ),
  email = "info@inbo.be",
  website = "https://vlaanderen.be/inbo/en",
  logo = "https://inbo.github.io/checklist/reference/figures/logo-en.png",
  ror = "00j54wy13",
  orcid = TRUE,
  zenodo = "inbo",
  rightsholder = "shared",
  funder = "when no other",
  license = list(
    package = c(
      `GPL-3` = paste(
        "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
        "main/inst/generic_template/gplv3.md",
        sep = "/"
      ),
      MIT = paste(
        "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
        "main/inst/generic_template/mit.md",
        sep = "/"
      )
    ),
    project = c(
      `CC BY 4.0` = paste(
        "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
        "main/inst/generic_template/cc_by_4_0.md",
        sep = "/"
      )
    ),
    data = c(
      `CC0` = paste(
        "https://raw.githubusercontent.com/inbo/checklist",
        "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template",
        "cc0.md",
        sep = "/"
      )
    )
  )
)
inbo
```

    ## name
    ## - nl-BE: Instituut voor Natuur- en Bosonderzoek (INBO)
    ## - fr-FR: Institut de Recherche sur la Nature et les Forêts (INBO)
    ## - en-GB: Research Institute for Nature and Forest (INBO)
    ## - de-DE: Institut für Natur- und Waldforschung (INBO)
    ## email: info@inbo.be
    ## ROR: 00j54wy13
    ## ORCID is required
    ## zenodo community: inbo
    ## website: https://www.vlaanderen.be/inbo/en-gb
    ## logo: https://inbo.github.io/checklist/reference/figures/logo-en.png
    ## copyright holder: shared
    ## funder: when no other
    ## allowed licenses:
    ## - package: GPL-3 or MIT
    ## - project: CC BY 4.0
    ## - data: CC0

``` r

anb <- org_item$new(
  name = c(
    `nl-BE` = "Agentschap voor Natuur en Bos (ANB)",
    `en-GB` = "Agency for Nature & Forests (ANB)"
  ),
  email = "natuurenbos@vlaanderen.be",
  ror = "04wcznf70",
  license = list(
    package = character(0),
    project = character(0),
    data = character(0)
  )
)
anb
```

    ## name
    ## - nl-BE: Agentschap voor Natuur en Bos (ANB)
    ## - en-GB: Agency for Nature & Forests (ANB)
    ## email: natuurenbos@vlaanderen.be
    ## ROR: 04wcznf70
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: no requirements
    ## - project: no requirements
    ## - data: no requirements

Then you can create the `org_list` object.

``` r

inbo_org <- org_list$new(inbo, anb, git = "https://github.com/inbo")
inbo_org
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - nl-BE: Instituut voor Natuur- en Bosonderzoek (INBO)
    ## - fr-FR: Institut de Recherche sur la Nature et les Forêts (INBO)
    ## - en-GB: Research Institute for Nature and Forest (INBO)
    ## - de-DE: Institut für Natur- und Waldforschung (INBO)
    ## email: info@inbo.be
    ## ROR: 00j54wy13
    ## ORCID is required
    ## zenodo community: inbo
    ## website: https://www.vlaanderen.be/inbo/en-gb
    ## logo: https://inbo.github.io/checklist/reference/figures/logo-en.png
    ## copyright holder: shared
    ## funder: when no other
    ## allowed licenses:
    ## - package: GPL-3 or MIT
    ## - project: CC BY 4.0
    ## - data: CC0
    ## 
    ## ################################################################################
    ##  organisation 2 
    ## ................................................................................
    ## name
    ## - nl-BE: Agentschap voor Natuur en Bos (ANB)
    ## - en-GB: Agency for Nature & Forests (ANB)
    ## email: natuurenbos@vlaanderen.be
    ## ROR: 04wcznf70
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: no requirements
    ## - project: no requirements
    ## - data: no requirements
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/inbo
    ## ################################################################################

The final step is to store the `org_list` into a `checklist` repository.
The [`write()`](https://rdrr.io/r/base/write.html) method creates a
`organisation.yml` file in the root of the repository. Commit this file
to the repository and push it to the remote.

``` r

path_to_checklist_repo <- tempfile("checklist")
dir.create(path_to_checklist_repo, recursive = TRUE)
inbo_org$write(path_to_checklist_repo)
```

    ## /tmp/RtmpgyyCN4/checklist26b93e0d4ec9/organisation.yml

### Getting the default

Run
[`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md)
in a project to get the default organisation list. This function
determines the organisation based on the git remote `origin` of the
project. Hence it only works for git projects. It look for the an
`organisation.yml` file in the root of the `main` branch of the
repository `checklist` of the git organisation. Note that you can have
projects from different organisations on the same machine.

[`get_default_org_list()`](https://inbo.github.io/checklist/reference/get_default_org_list.md)
stores the information in the configuration settings of `checklist`. You
only need to run it once for every organisation in case the
organisations defaults change. After that you can simply run
`org_list$new()$read()`. That function either returns the local
`organisation.yml` file or fetches the default from the `checklist`
configuration.

``` r

# setting up a demo git repository
test_dir <- tempfile("test")
dir.create(test_dir)
library(gert)
```

    ## Linking to libgit2 v1.4.2, ssh support: YES

    ## No global .gitconfig found in: /github/home

    ## No default user configured

``` r

git_init(test_dir)
git_remote_add(
  url = "https://github.com/ThierryO/test",
  name = "origin",
  repo = test_dir
)
# get the default organisation list from https://github.com/ThierryO/checklist
my_org <- get_default_org_list(test_dir)
my_org
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - en-GB: muscardinus
    ## email: info@muscardinus.be
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: GPL-3.0
    ## - project: CC BY-SA 4.0
    ## - data: CC BY-NC-SA 4.0
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/ThierryO
    ## ################################################################################

### Adding an `org_item` to an `org_list` object

You can add an `org_item` to an `org_list` object using the `add_item()`
method. At this point it is required to use the
[`write()`](https://rdrr.io/r/base/write.html) method to store the
`org_list` object in the local `organisation.yml` file.

``` r

# let's create an empty org_list so we can use its methods
empty_org <- org_list$new()
# read the organisation list
# because we didn't write the organisation.yml file, it will fetch the
# default from the configuration
list.files(test_dir)
```

    ## character(0)

``` r

empty_org$read(test_dir)
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - en-GB: muscardinus
    ## email: info@muscardinus.be
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: GPL-3.0
    ## - project: CC BY-SA 4.0
    ## - data: CC BY-NC-SA 4.0
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/ThierryO
    ## ################################################################################

``` r

# add an organisation item to the organisation list
my_org <- my_org$add_item(anb)
my_org
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - en-GB: muscardinus
    ## email: info@muscardinus.be
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: GPL-3.0
    ## - project: CC BY-SA 4.0
    ## - data: CC BY-NC-SA 4.0
    ## 
    ## ################################################################################
    ##  organisation 2 
    ## ................................................................................
    ## name
    ## - nl-BE: Agentschap voor Natuur en Bos (ANB)
    ## - en-GB: Agency for Nature & Forests (ANB)
    ## email: natuurenbos@vlaanderen.be
    ## ROR: 04wcznf70
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: no requirements
    ## - project: no requirements
    ## - data: no requirements
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/ThierryO
    ## ################################################################################

``` r

# it still isn't written to the local organisation.yml file
list.files(test_dir)
```

    ## [1] "organisation.yml"

``` r

empty_org$read(test_dir)
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - en-GB: muscardinus
    ## email: info@muscardinus.be
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: GPL-3.0
    ## - project: CC BY-SA 4.0
    ## - data: CC BY-NC-SA 4.0
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/ThierryO
    ## ################################################################################

``` r

# use the write method to create the organisation.yml file
my_org$write(test_dir)
```

    ## /tmp/RtmpgyyCN4/test26b9165cf775/organisation.yml

``` r

list.files(test_dir)
```

    ## [1] "organisation.yml"

``` r

empty_org$read(test_dir)
```

    ## 
    ## ################################################################################
    ##  organisation 1 
    ## ................................................................................
    ## name
    ## - en-GB: muscardinus
    ## email: info@muscardinus.be
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: GPL-3.0
    ## - project: CC BY-SA 4.0
    ## - data: CC BY-NC-SA 4.0
    ## 
    ## ################################################################################
    ##  organisation 2 
    ## ................................................................................
    ## name
    ## - nl-BE: Agentschap voor Natuur en Bos (ANB)
    ## - en-GB: Agency for Nature & Forests (ANB)
    ## email: natuurenbos@vlaanderen.be
    ## ROR: 04wcznf70
    ## copyright holder: optional
    ## funder: optional
    ## allowed licenses:
    ## - package: no requirements
    ## - project: no requirements
    ## - data: no requirements
    ## 
    ## ################################################################################
    ## git organisation: https://github.com/ThierryO
    ## ################################################################################

### Defining your organisations’ coding style rules

You can define your organisations’ coding style rules in the
organisations’ `checklist` repository. Create a `.lintr` file in the
root of the repository. This file will be used by `checklist` when
running
[`check_lintr()`](https://inbo.github.io/checklist/reference/check_lintr.md)
check on projects that belong to the organisation. For more information
on the `.lintr` file, please refer to the [lintr
documentation](https://lintr.r-lib.org/articles/lintr.html#configuring-linters).

If you don’t provide a `.lintr` file in your organisations’ `checklist`
repository, the user can provide a local `.lintr` file in the project
directory. Otherwise the default `.lintr` file provided with the
`checklist` package will be used.

### Defining your organisations’ `pkgdown` styling

You can provide `css` styling by placing a `pkgdown.css` file at the
root of the `checklist` repository. You can place other files
(e.g. images, fonts, …) in the `pkgdown` folder of the repository. These
files will be placed in the `man/figures` folder of the package to make
them available when building the `pkgdown` site.

## FAQ

1.  Can I use `checklist` without git?

    Yes, you can use `checklist` without git. `checklist` will only
    check the rules defined in the local `organisation.yml`

2.  Is a `checklist` repository at the organisation level required to
    use `checklist`?

    No, you can use `checklist` without a `checklist` repository. Having
    no `checklist` repository means that you don’t enforce any
    organisation rules.

3.  Do I need to add an `organisation.yml` file to my project?

    No, you do not need to add an `organisation.yml` file to your
    project unless you want to add specific rules for your project. Note
    that these still need to comply with the organisation rules defined
    in the `checklist` repository.
