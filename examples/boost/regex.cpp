#include <boost/regex.hpp>
#include <iostream>
#include <iterator>
#include <string>

int main() {
  using namespace boost;

  std::string s
      = "Some people, when confronted with a problem, think "
        "\"I know, I'll use regular expressions.\" "
        "Now they have two problems.";

  regex self_regex("REGULAR EXPRESSIONS", regex_constants::icase);
  if (regex_search(s, self_regex)) {
    std::cout << "Text contains the phrase 'regular expressions'\n";
  }

  regex nonws_regex("(\\S+)");
  regex word_regex("(\\w+)");
  sregex_iterator words_begin = sregex_iterator(s.begin(), s.end(), word_regex);
  sregex_iterator words_end = sregex_iterator();

  std::cout << "Found " << std::distance(words_begin, words_end) << " words\n";

  constexpr int N{6};
  std::cout << "Words greater than " << N << " characters:\n";
  for (sregex_iterator i = words_begin; i != words_end; ++i) {
    smatch match = *i;
    std::string match_str = match.str();
    if (match_str.size() > N) {
      std::cout << "  " << match_str << '\n';
    }
  }

  regex long_word_regex("(\\w{7,})");
  std::string new_s = regex_replace(s, long_word_regex, std::string("[$&]"));
  std::cout << new_s << '\n';

  {
    std::string text = "Quick brown fox";
    regex vowel_re("a|e|i|o|u");

    // write the results to an output iterator
    regex_replace(std::ostreambuf_iterator<char>(std::cout), text.begin(), text.end(), vowel_re,
                  std::string("'*'"));

    // construct a string holding the results
    std::cout << '\n' << regex_replace(text, vowel_re, std::string("[$&]")) << '\n';
  }

  return 0;
}
