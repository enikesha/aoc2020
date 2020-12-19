#!/usr/bin/perl -w
use strict;
use warnings;

sub calc {
    my $stack = shift;
    my @s = ();
    foreach (@$stack) {
        if (/\+/) {
            push @s, (pop(@s) + pop(@s));
        } elsif (/\*/) {
            push @s, (pop(@s) * pop(@s));
        } else {
            push @s, $_;
        }
    }
    return pop @s;
}

sub calc_sum {
    my ($lines, $pri) = @_;
    my $sum = 0;

    foreach (@$lines) {
        my @stack = ();
        my @ops = ();
        foreach (split //) {
            next if /\A \s* \z/x;
            push @stack, $_ if /\d/;
            push @ops, $_ if /\(/;
            if (/[+*]/) {
                while (@ops && ($$pri{$_} <= $$pri{$ops[-1]})) { push @stack, pop @ops; }
                push @ops, $_;
            } elsif (/\)/) {
                while (@ops && $ops[-1] ne "(") { push @stack, pop @ops; }
                pop @ops;
            }
        }
        while (@ops) { push @stack, pop @ops; }
        $sum += calc \@stack;
    }

    return $sum;
}

my @lines = <>;
my %pri1 = ('*' => 1, '+' => 1, '(' => 0);
print calc_sum(\@lines, \%pri1) . "\n";
my %pri2 = ('*' => 1, '+' => 2, '(' => 0);
print calc_sum(\@lines, \%pri2) . "\n";
