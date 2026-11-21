From VST Require Import floyd.proofauto.
From CRubyVerif.util Require Import scan_digits_theory scan_digits.

#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs.  mk_varspecs prog. Defined.

(* Notes for writing the contract:
   - On this target (aarch64) clightgen treats char as unsigned, so str has
     type tptr tuchar and its contents are bytes 0..255.
   - The global table can be described by
       data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table))
               (gv _ruby_digit36_to_number_table)
   - len < 0 means "scan until a non-digit"; restricting to 0 <= len first
     makes the proof much easier. *)
Definition ruby_scan_digits_spec :=
 DECLARE _ruby_scan_digits
  WITH gv : globals, str : val, sh : share, s : list Z, len : Z, base : Z,
       retlen : val, overflow : val
  PRE [ tptr tuchar, tlong, tint, tptr tulong, tptr tint ]
    PROP ( readable_share sh; 2 <= base <= 36;  0 <= len <= Zlength s; Forall (fun c => 0 <= c < 256) s )
    PARAMS (str; Vlong (Int64.repr len); Vint (Int.repr base); retlen; overflow)
    GLOBALS (gv)
    SEP ( data_at sh (tarray tuchar (Zlength s)) (map Vint (map Int.repr s)) str;
          data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table)) (gv _ruby_digit36_to_number_table);
          data_at_ Tsh tulong retlen;
          data_at_ Tsh tint overflow)
  POST [ tulong ]
     PROP ()
     RETURN (Vlong (Int64.repr (scan_value base len s)))
     SEP ( data_at sh (tarray tuchar (Zlength s)) (map Vint (map Int.repr s)) str;
           data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table)) (gv _ruby_digit36_to_number_table);
           data_at Tsh tulong (Vlong (Int64.repr (scan_len base len s))) retlen;
           data_at Tsh tint (Vint (Int.repr (overflow_flag (scan_value base len s)))) overflow).

Definition Gprog : funspecs := ltac:(with_library prog [ruby_scan_digits_spec]).

Lemma body_ruby_scan_digits :
  semax_body Vprog Gprog f_ruby_scan_digits ruby_scan_digits_spec.
Proof.
start_function.
forward. (* start = str *)
forward. (* ret = 0 *)
forward. (* mul_overflow = ~0UL / base *)
{ (* base <> 0, so the division is defined *)
  entailer!.
  match goal with H : Int.repr base = Int.zero |- _ =>
    apply (f_equal Int.signed) in H;
    rewrite Int.signed_repr in H by rep_lia;
    rewrite Int.signed_zero in H; lia
  end. }
forward. (* *overflow = 0 *)
forward_if.
{ (* len == 0: *retlen = 0; return 0 *)
  forward. forward.
  admit. }
(* len <> 0: the do-while loop.
   Inv   : at the top of each iteration, i characters have been read.
   continue: after the body, before len < 0 || --len (len not yet decremented).
   break : both exits (non-digit found, or len characters read). *)
forward_loop
  (EX i : Z,
   PROP (0 <= i < len; i <= valid_prefix_len base s)
   LOCAL (temp _str (offset_val i str); temp _start str;
          temp _ret (Vlong (Int64.repr (prefix_value base s i)));
          temp _mul_overflow (Vlong (Int64.repr (Int64.max_unsigned / base)));
          temp _len (Vlong (Int64.repr (len - i)));
          temp _base (Vint (Int.repr base));
          temp _retlen retlen; temp _overflow overflow; gvars gv)
   SEP (data_at sh (tarray tuchar (Zlength s)) (map Vint (map Int.repr s)) str;
        data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table))
                (gv _ruby_digit36_to_number_table);
        data_at_ Tsh tulong retlen;
        data_at Tsh tint (Vint (Int.repr (overflow_flag (prefix_value base s i)))) overflow))
continue:
  (EX i : Z,
   PROP (1 <= i <= len; i <= valid_prefix_len base s)
   LOCAL (temp _str (offset_val i str); temp _start str;
          temp _ret (Vlong (Int64.repr (prefix_value base s i)));
          temp _mul_overflow (Vlong (Int64.repr (Int64.max_unsigned / base)));
          temp _len (Vlong (Int64.repr (len - i + 1)));
          temp _base (Vint (Int.repr base));
          temp _retlen retlen; temp _overflow overflow; gvars gv)
   SEP (data_at sh (tarray tuchar (Zlength s)) (map Vint (map Int.repr s)) str;
        data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table))
                (gv _ruby_digit36_to_number_table);
        data_at_ Tsh tulong retlen;
        data_at Tsh tint (Vint (Int.repr (overflow_flag (prefix_value base s i)))) overflow))
break:
  (PROP ()
   LOCAL (temp _str (offset_val (scan_len base len s) str); temp _start str;
          temp _ret (Vlong (Int64.repr (scan_value base len s)));
          temp _retlen retlen; temp _overflow overflow; gvars gv)
   SEP (data_at sh (tarray tuchar (Zlength s)) (map Vint (map Int.repr s)) str;
        data_at Ers (tarray tschar 256) (map Vbyte (map Byte.repr digit_table))
                (gv _ruby_digit36_to_number_table);
        data_at_ Tsh tulong retlen;
        data_at Tsh tint (Vint (Int.repr (overflow_flag (scan_value base len s)))) overflow)).
- (* entry: the state before the loop satisfies Inv with i = 0 *)
  admit.
- (* body: from Inv, run one iteration; reach continue or break *)
  admit.
- (* increment: from continue, len < 0 || --len; back to Inv or break *)
  admit.
- (* after the loop: *retlen = str - start; return ret *)
  admit.
Admitted.
