#!/usr/bin/env perl

# Copyright (C) 2015-2018 Toshinori Sato (@overlast)
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

sub _normalize {
    my ($str) = @_;
    $str =~ s|^[ ]+||g;
    $str =~ s|[ ]+$||g;
    return $str;
}

sub main {
    my $seed_dict = $ARGV[0];
    my $ext_dict = $ARGV[1];

    open my $seed_in, '<:utf8', $seed_dict;
    open my $ext_in, '<:utf8', $ext_dict;
    open my $ext_out, '>:utf8', $seed_dict.".ext";

    my $eline = readline($ext_in);
    while (my $sline = readline($seed_in)) {
        $sline =~ s|\n||;
        my @sline_cols = split /\,/, $sline;
        my $sline_key = $sline_cols[0].",".$sline_cols[1];

        # reached EOF of $ext_in and $eline is empty
        if ((eof($ext_in)) && ($eline eq "")) {
            print $ext_out $sline.",\n";
            next;
        }

        $eline =~ s|\n||;
        my @eline_cols = split /\t/, $eline;
        my $eline_key = $eline_cols[0];

        while ((! eof($ext_in)) && (($sline_key cmp $eline_key) == 1)) {
            # $eline_key won't match $sline_key
            $eline = readline($ext_in);
            $eline =~ s|\n||;
            @eline_cols = split /\t/, $eline;
            $eline_key = $eline_cols[0];
        }

        if ($sline_key eq $eline_key) {
            print $ext_out $sline.",".&_normalize($eline_cols[1])."\n";
        }
        elsif (($sline_key cmp $eline_key) == -1) {
            # There is a possibility that $eline_key will match $sline_key
            print $ext_out $sline.",\n";
        }
        else {
            # $eline_key won't match $sline_key
            print $ext_out $sline.",\n";
            if (eof($ext_in)) {
                $eline = ""; # It will be cause printing only $sline
            }
        }
    }

    close $ext_out;
    close $ext_in;
    close $seed_in;
}

&main();
