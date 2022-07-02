defmodule CraqValidation do
  @moduledoc """
  Documentation for `CraqValidation`.
  """

  @doc """
  Validates user Responses for a CRAQ in comparison to the Questionaire

  ## Examples

      iex> questions = [
      ...>   %{ text: "q1", options: [%{ text: "an option" }, %{ text: "another option" }] },
      ...>   %{ text: "q2", options: [%{ text: "an option" }, %{ text: "another option" }] }
      ...> ]
      iex> answers = %{ q0: 0, q1: 0 }
      iex> CraqValidation.new(questions, answers)
      %{ valid?: true, errors: %{} }

      iex> questions = [
      ...>   %{ text: "q1", options: [%{ text: "an option" }, %{ text: "another option" }] },
      ...>   %{ text: "q2", options: [%{ text: "an option" }, %{ text: "another option" }] }
      ...> ]
      iex> answers = %{ q0: 0 }
      iex> CraqValidation.new(questions, answers)
      %{ valid?: false, errors: %{ q1: "was not answered" } }

  """
  @type option :: %{
          text: String.t(),
          complete_if_selected: boolean() | nil
        }

  @type question :: %{
          text: String.t(),
          options: list(option)
        }

  @type questions :: list(question)

  @type answers :: map()

  @type result :: %{
          valid?: boolean(),
          errors: map()
        }

  @type accumulator :: %{
          valid?: boolean(),
          errors: map(),
          completion_flag: boolean(),
          answers: map(),
          index: integer()
        }

  @not_answered "was not answered"
  @not_needed "was answered even though a previous response indicated that the questions were complete"
  @invalid_answer "has an answer that is not on the list of valid answers"

  @spec new(questions(), answers()) :: result()
  def new(questions, nil), do: new(questions, %{})

  def new(questions, answers) do
    accumulator = %{
      valid?: true,
      errors: %{},
      completion_flag: false,
      answers: answers,
      index: 0
    }

    questions
    |> Enum.reduce(accumulator, &check_response(&1, &2))
    |> Map.drop([:completion_flag, :answers, :index])
  end

  @spec check_response(question(), accumulator()) :: accumulator()
  defp check_response(_question, %{completion_flag: completion_flag} = accumulator)
       when completion_flag == true do
    if Map.keys(accumulator.answers) == [] do
      accumulator
    else
      put_error(accumulator, @not_needed)
    end
  end

  defp check_response(question, accumulator) do
    {answer, accumulator} = get_parameters(accumulator)

    case check_for_option(question.options, answer) do
      :not_answered ->
        put_error(accumulator, @not_answered)

      nil ->
        put_error(accumulator, @invalid_answer)

      option ->
        accumulator =
          if Map.get(option, :complete_if_selected, nil) == true do
            accumulator
            |> Map.put(:completion_flag, true)
          else
            accumulator
          end

        manage_index(accumulator)
    end
  end

  @spec put_error(accumulator(), binary()) :: accumulator()
  defp put_error(accumulator, msg) do
    index = parse_index(accumulator.index)
    errors = Map.put(accumulator.errors, index, msg)

    accumulator
    |> Map.put(:valid?, false)
    |> Map.put(:errors, errors)
    |> manage_index()
  end

  @spec check_for_option(list(option()), integer() | atom()) :: option() | atom()
  defp check_for_option(_options, :not_answered), do: :not_answered
  defp check_for_option(options, answer), do: Enum.at(options, answer)

  @spec manage_index(accumulator()) :: accumulator()
  defp manage_index(acc), do: Map.put(acc, :index, acc.index + 1)

  @spec parse_index(integer()) :: atom()
  defp parse_index(i), do: "q#{i}" |> String.to_atom()

  @spec get_parameters(accumulator()) :: tuple()
  defp get_parameters(accumulator) do
    index = parse_index(accumulator.index)
    answer = Map.get(accumulator.answers, index, :not_answered)
    rest = Map.drop(accumulator.answers, [index])
    accumulator = Map.put(accumulator, :answers, rest)

    {answer, accumulator}
  end
end
