#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'cgi'
require 'nkf'

def normalize_str(str)
	# Decode HTML tags in Tweet
	#	> http://www.xmisao.com/2014/03/09/how-to-encode-decode-html-entities-in-ruby.html
	str = CGI.unescapeHTML(str)
	

	#####
	# Implement string normalization for NEologd
	#	> https://github.com/neologd/mecab-ipadic-neologd/wiki/Regexp
	#####
	#
	# 全角英数字は半角に置換
	str.tr!('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')      
	# 半角カタカナは全角に置換 (NKF default)
	# アルファベットといくつかの記号（全角スペース含む）をASCIIに変換 (-Z1)
	# ｢｣は全角記号に置換 (NKF default)
	#	> http://qiita.com/wada811/items/fd7edce8ce885354fc89
	#	> http://docs.ruby-lang.org/ja/1.9.3/class/NKF.html
	str = NKF.nkf("-w -Z1", str).gsub(/\s+/, ' ')
	# ハイフンマイナスっぽい文字を置換
	#	> http://d.hatena.ne.jp/y-kawaz/20101112/1289554290
	hyphen_like_chars = '\u02D7\u058A\u2010\u2011\u2012\u2013\u2043\u207B\u208B\u2212'
	str.gsub!(/[#{hyphen_like_chars}]/, '-')
	# 長音記号っぽい文字を置換
	longsound_like_chars = '\u2014\u2015\u2500\u2501\uFE63\uFF0D\uFF70'
	str.gsub!(/[#{longsound_like_chars}]/, 'ー')
	# チルダっぽい文字は削除
	tilt_like_chars = '\u007E\u223C\u223E\u301C\u3030\uFF5E'
	str.gsub!(/[#{tilt_like_chars}]/, '')
	# ひらがな・全角カタカナ・半角カタカナ・漢字(全角記号は半角に置換された)間に含まれる半角スペースは削除
	# ひらがな・全角カタカナ・半角カタカナ・漢字と「半角英数字」の間に含まれる半角スペースは削除
	#	> http://ruby-doc.org/core-1.9.3/Regexp.html
	lhs_chars = '\p{Hiragana}\p{Katakana}\p{Han}'
	rhs_chars = '\p{Hiragana}\p{Katakana}\p{Han}\p{Alnum}'
	str.gsub!(/([#{lhs_chars}]+)(\s+)(?=[#{rhs_chars}]+)/, '\1')
	str.gsub!(/([#{rhs_chars}]+)(\s+)(?=[#{lhs_chars}]+)/, '\1')
	# 解析対象テキストの先頭と末尾の半角スペースは削除
	str.strip!


	return str
end


if __FILE__ == $0
	puts "Examples in https://github.com/neologd/mecab-ipadic-neologd/wiki/Regexp: "
	puts 

	str1 = "　　　ＰＲＭＬ　　副　読　本　　　"
	str2 = "Coding the Matrix"
	str3 = "南アルプスの　天然水　Ｓｐａｒｋｉｎｇ　Ｌｅｍｏｎ　レモン一絞り"
		
	puts "Original:   #{str1}"
	puts "Normalized: #{normalize_str(str1)}"
	puts
	puts "Original:   #{str2}"
	puts "Normalized: #{normalize_str(str2)}"
	puts
	puts "Original:   #{str3}"
	puts "Normalized: #{normalize_str(str3)}"
	puts


end
