# stat20quiz Custom Format

## Installing

```bash
quarto use template stat20/stat20quiz
```

This will install the extension and create an example qmd file that you can use as a starting place for your quiz.

## Try the template!

See [template.qmd](template.qmd) for an example of all of the features of this format. Read more about them below.


## Using

### Create a new question

Create a new question by making a new level two header `##`, the same way that you'd make a new slide in reveal. Example:

```markdown
##

What is your name?
```

### Flag a question as true-false

You can indicate that a question is true/false and provide a blank spot to write an answer at the beginning of the question, by adding the `.tf` class to the level two header.

Example:

```markdown
## {.tf}

The *mean* is a measure of spread.
```

### Create multiple choice bubbles

You can create bubbles for different multiple choice answers using a bullet list.

Example:

```markdown
##

What is the definition of a *p-value*??

- The probability that the null hypothesis is true.
- The probability of observing our test statistic or more extreme when the null hypothesis is true.
- The probability of observing our test statistic or more extreme when the null hypothesis is false.
```

You can spread the answers over multiple columns by separating each bullet point with a line that contains only `* * *`.

Example:

```markdown
##

Which are measures of center?

- SD
* * *
- IQR
* * *
- Median
```

### Create checkboxes

You can change the shape used to indicate each choice in a multiple choice question by adding the `.select-all` class to the question.

Example:
```markdown
## {.select-all}

Which are the names of US states?

- California
- Italy
- Alabama
- Canada
```

### Add name boxes

The template defaults to having one box in the header for a name. This can be increased by using the `n-names` key in the document YAML.

Example:

```yaml
---
title: Quiz 1
format:
  stat20quiz-pdf:
    n-names: 3
---
```

There is space for 1-3 names.

### Make versions

You can make different versions, A-Z, by adding a version capital letter under the version key.

Example:

```yaml
---
title: Quiz 1
format:
  stat20quiz-pdf:
    version: A
---
```

This version will appear at the right side of the header after the `title`.

You can write version-specific inline content by wrapping it in a bracketed span and giving it a class of the version letter: `.vA` through `.vZ`.

Example:

```
The *mean* is a measure of [spread]{.vA}[center]{.vB}.
```

When `version: A` in the document YAML, that line will read, `The *mean* is a measure of spread`. When `version: B`, it will read `The *mean* is a measure of center`. Note that you can add multiple version classes to the same span.

### Add Directions

You can draw attention to directions by wrapping the text is a fenced div with the class `.directionsbox`.

Example:

```markdown
:::{.directionsbox}
Clearly write *True* or *False* on each blank line below.
:::
```

