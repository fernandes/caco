require "test_helper"

class InsideLinux < Trailblazer::Operation
  step :process

  def process(ctx, **)
    p "Process Linux"
    true
  end
end

class InsideDarwin < Trailblazer::Operation
  step :process

  def process(ctx, **)
    p "Process Darwin"
    true
  end
end

class Inside < Trailblazer::Operation
  step :first
  step Nested(:build_os!)
  step :inside1, Output(:success) => End(:boom)
  step :declined

  def first(ctx, **)
    ctx[:foo] = ctx.key?(:foo) ? ctx[:foo] : "new foooooo"
    true
  end

  def build_os!(ctx, os:, **)
    puts "building os?"
    return InsideDarwin if os == "Darwin"
    return InsideLinux
  end

  def inside1(ctx, foo:, **)
    p "foo: #{foo}"
    puts "Inside#inside1 foo: #{foo}"
    ctx[:foo] = "baz"
    ctx[:file_written] = true
    true
  end

  def declined(ctx, foo:, **)
    true
  end
end

class Debugging < Trailblazer::Operation
  step :step1
  step :step2
  step :step3
  step Subprocess(Inside),
    Output(:boom) => Id(:step4),
    input: [:foo, :os],
    output: {foo: :foo, file_written: :file_written}
  step :step4
  fail :log_error

  def step1(ctx, params:, **)
    ctx[:foo] = params[:foo]
    ctx[:os] = params[:os]
    # binding.pry
    # then trbreaks
    # then trbreaks Inside
    p "hello"
    true
  end

  def step2(ctx, params:, **)
    p "hello"
    true
  end

  def step3(ctx, params:, **)
    p "hello"
    true
  end

  def step4(ctx, params:, foo:, file_written:, **)
    puts "foo: #{foo}"
    puts "file_written: #{file_written}"
    true
  end

  def log_error(ctx, params:, **)
    puts "loggin error"
  end
end

class DebuggingTest < Minitest::Test
  def test_set_single_value
    # result = described_class.(params: {name: "foo"})
    # assert result.success?

    # params = { params: {os: "Darwin", foo: "foo"} }
    # Trailblazer::Developer.wtf?(Debugging, params)
    # result = Debugging.(params: {foo: "foo"})
    # result
  end
end
