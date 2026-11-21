/* Extracted from CRuby util.c (ruby_scan_digits) for verification with VST.
 * Source: ruby/ruby@3e6368577177b3c3e2119fec09fb0f69edccabee util.c
 *
 * Original copyright notice of util.c:
 *   Copyright (C) 1993-2008 Yukihiro Matsumoto
 * CRuby is dual-licensed under the Ruby License and the 2-clause BSD license.
 * This file is redistributed under the 2-clause BSD license; see
 * src/LICENSE.CRuby.
 *
 * Changes from the original:
 *  - ssize_t / size_t are replaced by long / unsigned long (LP64)
 *  - RBIMPL_ASSERT_OR_ASSUME(2 <= base <= 36) is moved to the precondition
 *  - NO_SANITIZE annotation is removed
 */

const signed char ruby_digit36_to_number_table[] = {
    /*     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f */
    /*0*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*1*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*2*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*3*/  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
    /*4*/ -1,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
    /*5*/ 25,26,27,28,29,30,31,32,33,34,35,-1,-1,-1,-1,-1,
    /*6*/ -1,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
    /*7*/ 25,26,27,28,29,30,31,32,33,34,35,-1,-1,-1,-1,-1,
    /*8*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*9*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*a*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*b*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*c*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*d*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*e*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    /*f*/ -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
};

unsigned long
ruby_scan_digits(const char *str, long len, int base, unsigned long *retlen, int *overflow)
{
    const char *start = str;
    unsigned long ret = 0, x;
    unsigned long mul_overflow = (~(unsigned long)0) / base;

    *overflow = 0;

    if (!len) {
        *retlen = 0;
        return 0;
    }

    do {
        int d = ruby_digit36_to_number_table[(unsigned char)*str++];
        if (d == -1 || base <= d) {
            --str;
            break;
        }
        if (mul_overflow < ret)
            *overflow = 1;
        ret *= base;
        x = ret;
        ret += d;
        if (ret < x)
            *overflow = 1;
    } while (len < 0 || --len);
    *retlen = str - start;
    return ret;
}
