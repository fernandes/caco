require "test_helper"

class TrablazerBackTo < Trailblazer::Operation
  class NestedOp < Trailblazer::Operation
    step :do_it!

    def do_it!(ctx, **)
      ctx[:do_it] = "do"
      true
    end
  end

  pass :initial_check, Output(:success) => Id(:nested)
  step Subprocess(NestedOp), magnetic_to: nil, id: :nested
  step :execute_anyway, magnetic_to: :success

  def initial_check(ctx, params:, **)
    params[:nested]
  end

  def execute_anyway(ctx, **)
    ctx[:anyway] = true
    true
  end
end

class TrablazerBackToTest < Minitest::Test
  def test_nested_true
    params = { params: {nested: true} }
    # Dev.wtf?(described_class, params)

    result = described_class.(params)
    assert result.success?
    assert result[:anyway]
    assert_equal "do", result[:do_it]
  end

  def test_nested_false
    params = { params: {nested: false} }
    # Dev.wtf?(described_class, params)

    result = described_class.(params)
    assert result.success?
    assert result[:anyway]
    refute result[:do_it]
  end
end
