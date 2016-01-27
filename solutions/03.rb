class RationalSequence
  include Enumerable

  def initialize(members_count)
    @members_count = members_count
  end

  def each
    numerator = 0
    denominator = 0

    (0...@members_count).each do
      if numerator % 2 == denominator % 2
        numerator += 1
        denominator = [denominator - 1, 1].max
      else
        denominator += 1
        numerator = [numerator - 1, 1].max
      end

      member = Rational(numerator, denominator)
      member.numerator == numerator or redo

      yield member
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(members_count)
    @members_count = members_count
  end

  def each
    prime_candidate = 2

    (0...@members_count).each do
      if ! DrunkenMathematician.prime?(prime_candidate)
        prime_candidate += 1 and redo
      end

      yield prime_candidate
      prime_candidate += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(members_count, first: 1, second: 1)
    @members_count = members_count
    @first = first
    @second = second
  end

  def each
    sequence = [@first, @second]

    (0...@members_count).each do |member_index|
      sequence.push(sequence.last(2).reduce(:+))

      yield sequence[member_index]
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    grouped_rationals = RationalSequence.new(n).partition do |rational|
      fraction_members = [rational.numerator, rational.denominator]
      fraction_members.any? { |member| prime?(member) }
    end

    prime_fractions_product = grouped_rationals[0].reduce(:*) || 1
    non_prime_fractions_product = grouped_rationals[1].reduce(:*) || 1

    prime_fractions_product / non_prime_fractions_product
  end

  def aimless(n)
    primes = PrimeSequence.new(n)

    primes.each_slice(2).map { |pair| Rational(pair[0], pair[1] || 1) }.reduce(:+) || 0
  end

  def worthless(n, first: 1, second: 1)
    fibonacci_n = FibonacciSequence.new(n, first: first, second: second).to_a.last
    rationals = RationalSequence.new(Float::INFINITY)
    rationals_sum = Rational(0)

    rationals.take_while { |rational| (rationals_sum += rational) <= fibonacci_n }
  end

  def prime?(candidate)
    candidate >= 2 and (2...candidate).none? { |divisor| candidate % divisor == 0 }
  end
end