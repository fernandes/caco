require "test_helper"

class CheckContract < Trailblazer::Operation
  NoContract = Class.new(Trailblazer::Activity::Signal)

  step :check_contract
  step :foo

  def check_contract(ctx, params:, **)
    return false if params[:no_contract]
    true
  end

  def foo(ctx, params:, **)
    true
  end
end


class TrablazerOutputContract < Trailblazer::Operation
  # Usar Nested() no trb 2.0
  step Subprocess(CheckContract),
    Output(:failure) => End(:no_contract)
end

class TrablazerOutputContractTest < Minitest::Test
  def test_nested_no_contract
    params = { params: {no_contract: true} }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    refute result.success?
    assert_equal :no_contract, result.event.to_h[:semantic]
  end

  def test_nested_contract
    params = { params: {no_contract: false} }
    # Dev.wtf?(described_class, params)

    result = described_class.(params)
    assert result.success?
    assert_equal :success, result.event.to_h[:semantic]
  end
end
