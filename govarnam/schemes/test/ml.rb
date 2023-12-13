# encoding: utf-8

class TestML < Minitest::Test
  def setup
    @varnam = get_varnam_handle('ml')
    @varnam.config(Varnam::VARNAM_CONFIG_SET_TOKENIZER_SUGGESTIONS_LIMIT, 30)
  end

  def test_words
    list = {
      'peN' => 'പെൺ',

      # BEGIN Anusvara <-> ma complications
      'am_bEdkar' => 'അംബേദ്കർ',
      'manam_pOle' => 'മനംപോലെ',
      'kunnamkuLam' => 'കുന്നംകുളം',
      'pamkthi' => 'പംക്തി',
      'kambiyil' => 'കമ്പിയിൽ',
      'mvOnE' => 'മ്വോനേ',
      'mvOnoossE' => 'മ്വോനൂസ്സേ',
      'manushyan' => 'മനുഷ്യൻ',
      'mlEchcham' => 'മ്ലേച്ചം',
      # END Anusvara <-> ma complications

      'kiLivaathil' => 'കിളിവാതിൽ',
      'kiLivaathilil' => 'കിളിവാതിലിൽ',
      'thaazhvara' => 'താഴ്വര',
      'thaazh_vara' => 'താഴ്‌വര',
      'ANkiLi' => 'ആൺകിളി'
    }
    list.each do |pattern, expected|
      # TODO assert length of result array too
      assert_equal expected, @varnam.transliterate(pattern)[0].Word
    end
  end

  def test_reverse_transliteration
    list = {
      'മലയാളം' => %w[malayaaLam malayaaLam_ malayALam malayALam_ malayaalam malayaalam_ malayAlam malayAlam_ malayaLam malayaLam_ malayalam malayalam_]
    }

    list.each do |word, expected|
      assert_equal expected, @varnam.reverse_transliterate(word)
    end
  end
end
