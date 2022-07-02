defmodule CraqValidationTest do
  use ExUnit.Case
  doctest CraqValidation

  describe "it is invalid with no answers" do
    test "test1" do
      questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
      answers = %{}

      assert_error(
        questions,
        answers,
        %{q0: "was not answered"}
      )
    end
  end

  describe "it is invalid with nil answers" do
    test "test2" do
      questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
      answers = nil

      assert_error(
        questions,
        answers,
        %{q0: "was not answered"}
      )
    end
  end

  describe "errors are added for all questions" do
    test "test3" do
      questions = [
        %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]
      answers = nil

      assert_error(
        questions,
        answers,
        %{q0: "was not answered", q1: "was not answered"}
      )
    end
  end

  describe "it is valid when an answer is given" do
    test "test4" do
      questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}]}]
      answers = %{q0: 0}

      assert_valid(questions, answers)
    end
  end

  describe "it is valid when there are multiple options and the last option is chosen" do
    test "test5" do
      questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]}]
      answers = %{q0: 2}

      assert_valid(questions, answers)
    end
  end

  describe "it is invalid when an answer is not one of the valid answers" do
    test "test6" do
      questions = [%{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]}]
      answers = %{q0: 2}

      assert_error(
        questions,
        answers,
        %{q0: "has an answer that is not on the list of valid answers"}
      )
    end
  end

  describe "it is invalid when not all the questions are answered" do
    test "test7" do
      questions = [
        %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]
      answers = %{q0: 0}

      assert_error(
        questions,
        answers,
        %{q1: "was not answered"}
      )
    end
  end

  describe "it is valid when all the questions are answered" do
    test "test8" do
      questions = [
        %{text: "q1", options: [%{text: "an option"}, %{text: "another option"}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]

      answers = %{q0: 0, q1: 0}

      assert_valid(questions, answers)
    end
  end

  describe "it is valid when questions after complete_if_selected are not answered" do
    test "test9" do
      questions = [
        %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]

      answers = %{q0: 1}

      assert_valid(questions, answers)
    end
  end

  describe "it is invalid if questions after complete_if are answered" do
    test "test10" do
      questions = [
        %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]
      answers = %{q0: 1, q1: 0}

      assert_error(
        questions,
        answers,
        %{q1: "was answered even though a previous response indicated that the questions were complete"}
      )
    end
  end

  describe "it is valid if complete_if is not a terminal answer and further questions are answered" do
    test "test11" do
      questions = [
        %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]
      answers = %{q0: 0, q1: 1}

      assert_valid(questions, answers)
    end
  end

  describe "it is invalid if complete_if is not a terminal answer and further questions are not answered" do
    test "test12" do
      questions = [
        %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
        %{text: "q2", options: [%{text: "an option"}, %{text: "another option"}]}
      ]
      answers = %{q0: 0}

      assert_error(
        questions,
        answers,
        %{q1: "was not answered"}
      )
    end
  end

  defp assert_valid(questions, answers) do
    result = CraqValidation.new(questions, answers)
    assert result.valid?
  end

  defp assert_error(questions, answers, errors) do
    result = CraqValidation.new(questions, answers)

    refute result.valid?
    assert result.errors == errors
  end
end
