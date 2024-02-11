# stat20quiz Custom Format

## Installing

```bash
quarto use template stat20/stat20quiz
```

This will install the extension and create an example qmd file that you can use as a starting place for your quiz.

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

## Example

See [template.qmd](template.qmd) for an example of this functionality.

