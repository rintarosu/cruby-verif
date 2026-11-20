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
    PROP ( (* TODO *) )
    PARAMS (str; Vlong (Int64.repr len); Vint (Int.repr base); retlen; overflow)
    GLOBALS (gv)
    SEP ( (* TODO *) )
  POST [ tulong ]
    EX ret : Z,
     PROP ( (* TODO *) )
     RETURN (Vlong (Int64.repr ret))
     SEP ( (* TODO *) ).

Definition Gprog : funspecs := ltac:(with_library prog [ruby_scan_digits_spec]).

Lemma body_ruby_scan_digits :
  semax_body Vprog Gprog f_ruby_scan_digits ruby_scan_digits_spec.
Proof.
start_function.
(* TODO: forward through the initialization and the if (!len) branch, then use
   forward_loop with a loop invariant and a break postcondition for the
   do-while loop. *)
Admitted.
