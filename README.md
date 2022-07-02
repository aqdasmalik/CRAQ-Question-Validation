# CRAQ Question Validation

Change Request Acceptance Questions (CRAQ) are a set of questions that must be answered by any user proposing a change request. The questions can be different depending on each company's internal process and must be satisfactorily answered in order for a change request to proceed to approval.

## Basic Requirements

Questions are defined using an array of maps, and look like this:

```elixir
[
  %{
    text: 'What is the meaning of life?',
    options: [%{ text: '41' }, %{ text: '42' }]
  }
]
```

Answers, however, come back from the frontend as a map, not an array. If the set of questions is exactly the one question defined above, a valid answer map would look like this:

```elixir
%{q0: 1}
```

Which means that the answer to q0 is the second (using 0-based index) option - i.e. "42".

Some examples of invalid answers to the above question set would be:

```elixir
# invalid because it does not answer the question:
%{}

# invalid because it specifies option with index 3 as an answer
# to the question, but there are only 2 options to select from:
%{q0: 3}
```

## Terminal Questions

There is one more requirement for question set validation, which is that not all questions need to be answered in all cases.

By default, all questions need to be answered. But some questions can be terminal questions. This means that if you give a specific answer to them, you don't need to answer any more questions. Here is an example of this type of question set:

```elixir
[
  %{
    text: "What is the meaning of life?",
    options: [
      %{ text: "41" },
      %{ text: "42", complete_if_selected: true }
    ]
  },

  %{
    text: "Why did you not select 42 as the answer to the previous question?",
    options: [
      %{ text: "I'd far rather be happy than right any day" },
      %{ text: "I don't get that reference" }
    ]
  }
]
```

For options that have `complete_if_selected` set to `true`, if that option is selected by the user then the user doesn't need to answer any further questions. So here are some valid answers to the second question set:

```elixir
# Valid because both questions are answered:
%{q0: 0, q1: 0} 

# Valid because a terminal answer is chosen to the first question,
# so an answer to the second question is not required:
%{q0: 1} 
```

And here are some invalid answers to the second question set:

```elixir
# Invalid because there are no answers
%{}

# Invalid because there is only an answer to the first question,
# and it's not an answer that lets you skip remaining questions
%{q0: 0}

# Invalid because because a terminal answer is selected to the
# first question, but the second question is still answered
%{q0: 1, q1: 0}
```

## Errors

In order to report back to the user what the problems with their answers were, we need to generate an errors map that looks like this:

```elixir
%{
  q0: "has an answer that is not on the list of valid answers",
  q1: "was not answered",
  q2: "was answered even though a previous response indicated that the questions were complete"
}
```

These are the only three error messages that the validator needs to produce.
