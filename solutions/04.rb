class Card
  include Comparable

  class << self
    def ranks
      @ranks ||= [*2..10, :jack, :queen, :king, :ace]
    end

    def suits
      @suits ||= [:clubs, :diamonds, :hearts, :spades]
    end
  end

  attr_reader :rank
  attr_reader :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def <=>(other_card)
    suit_strength       = self.class.suits.index(@suit)
    other_suit_strength = self.class.suits.index(other_card.suit)

    if suit_strength < other_suit_strength
      -1
    elsif suit_strength > other_suit_strength
      +1
    else
      self.class.ranks.index(@rank) <=> self.class.ranks.index(other_card.rank)
    end
  end

  def previous
    previous_rank = self.class.ranks[self.class.ranks.index(@rank) - 1]
    previous_suit = self.class.suits[self.class.suits.index(@suit) - 1]

    if @rank == self.class.ranks.first
      Card.new(previous_rank, previous_suit)
    else
      Card.new(previous_rank, @suit)
    end
  end

  def next
    next_rank = self.class.ranks[self.class.ranks.index(@rank) + 1]
    next_suit = self.class.suits[self.class.suits.index(@suit) + 1]

    if @rank == self.class.ranks.last
      Card.new(self.class.ranks.first, next_suit || self.class.suits.first)
    else
      Card.new(next_rank, @suit)
    end
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end
end

class Hand
  def initialize(cards)
    @cards = cards
  end

  def size
    @cards.size
  end
end

class Deck
  include Enumerable

  @hand_size = 52

  class << self
    def ranks
      @ranks ||= Card.ranks
    end

    def suits
      @suits ||= Card.suits
    end

    attr_reader :hand_size

    def hand_class
      @hand_class ||= Hand
    end

    def card_class
      @card_class ||= Card
    end
  end

  def initialize(cards = [])
    @cards = generate_play_deck(cards)
  end

  def each
    @cards.each { |card| yield card }
  end

  def generate_play_deck(cards)
    ranks      = self.class.ranks
    suits      = self.class.suits
    card_class = self.class.card_class

    if not cards.empty?
      return cards.map { |card| card_class.new(card.rank, card.suit) }
    end

    suits.map { |suit| ranks.map { |rank| card_class.new(rank, suit) } }.flatten
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards[0]
  end

  def bottom_card
    @cards[-1]
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort!.reverse!
  end

  def to_s
    @cards.join("\n")
  end

  def deal
    hand_size  = self.class.hand_size
    hand_class = self.class.hand_class

    hand_class.new(@cards.shift(hand_size))
  end
end

class WarDeck < Deck
  class WarDeckHand < Hand
    def play_card
      @cards.shift
    end

    def allow_face_up?
      @cards.size <= 3
    end
  end

  @hand_size  = 26
  @hand_class = WarDeckHand
end

class BeloteDeck < Deck
  class BeloteDeckCard < Card
    @ranks = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  end

  class BeloteDeckHand < Hand
    def highest_of_suit(suit)
      @cards.select { |card| card.suit == suit }.max
    end

    def belote?
      suit_groups = @cards.group_by(&:suit).map { |_, group| group.map(&:rank) }

      suit_groups.any? { |group| (group & [:queen, :king]).length == 2 }
    end

    def tierce?
      has_sequence_of?(3)
    end

    def quarte?
      has_sequence_of?(4)
    end

    def quint?
      has_sequence_of?(5)
    end

    def carre_of_jacks?
      four_of_a_kind?(:jack)
    end

    def carre_of_nines?
      four_of_a_kind?(:nine)
    end

    def carre_of_aces?
      four_of_a_kind?(:aces)
    end

    def has_sequence_of?(size)
      seq_check = ->(group) { group.each_cons(2).all? { |a, b| b == a.next } }

      suit_groups     = @cards.sort.group_by(&:suit).values
      suit_groups_seq = suit_groups.map { |group| group.each_cons(size).to_a }
      suit_groups_seq.flatten!(1)

      suit_groups_seq.any?(&seq_check)
    end

    def four_of_a_kind?(rank)
      @cards.select { |card| card.rank == rank }.size == 4
    end

    private :has_sequence_of?, :four_of_a_kind?
  end

  @ranks      = BeloteDeckCard.ranks
  @hand_size  = 8
  @hand_class = BeloteDeckHand
  @card_class = BeloteDeckCard
end

class SixtySixDeck < Deck
  class SixtySixDeckCard < Card
    @ranks = [9, :jack, :queen, :king, 10, :ace]
  end

  class SixtySixDeckHand < Hand
    def twenty?(trump_suit)
      suit_groups = @cards.group_by(&:suit)
      suit_groups.delete(trump_suit)
      suit_groups = suit_groups.map { |_, group| group.map(&:rank) }

      suit_groups.any? { |group| (group & [:queen, :king]).length == 2 }
    end

    def forty?(trump_suit)
      trump_cards = @cards.select { |card| card.suit == trump_suit }.map(&:rank)

      (trump_cards & [:queen, :king]).length == 2
    end
  end

  @ranks      = SixtySixDeckCard.ranks
  @hand_size  = 6
  @hand_class = SixtySixDeckHand
  @card_class = SixtySixDeckCard
end