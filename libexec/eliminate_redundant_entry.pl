#!/usr/bin/env perl

# Copyright (C) 2015-2019 Toshinori Sato (@overlast)
#
#       https://github.com/neologd/mecab-ipadic-neologd
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use utf8;
use autodie;
use Encode;

my $input_file = $ARGV[0];
die "Input file is none." unless (-f $input_file);
my $output_file = $input_file.".same";

open my $in, '<:utf8', $input_file;
open my $out, '>:utf8', $output_file;
while (my $line = <$in>) {
    my @cols = split /,/, $line;
    next if ($cols[0] ne $cols[10]);
    print $out $line;
}
close $out;
close $in;
