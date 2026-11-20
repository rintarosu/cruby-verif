(* Mathematical definitions and facts for ruby_scan_digits (CRuby util.c). *)

From VST Require Import floyd.proofauto.

(* Value of character code c as a digit in base 36, or -1 if c is not a digit.
   This mirrors ruby_digit36_to_number_table. *)
Definition digit_value (c : Z) : Z :=
  if andb (48 <=? c) (c <=? 57) then c - 48        (* '0'..'9' *)
  else if andb (65 <=? c) (c <=? 90) then c - 55   (* 'A'..'Z' *)
  else if andb (97 <=? c) (c <=? 122) then c - 87  (* 'a'..'z' *)
  else -1.

(* Contents of ruby_digit36_to_number_table as a list of 256 integers. *)
Definition digit_table : list Z := map digit_value (upto 256).

Lemma Zlength_digit_table : Zlength digit_table = 256.
Proof. reflexivity. Qed.

(* TODO: define what ruby_scan_digits should compute. Suggested signatures:

   (* Number of leading characters of s that are valid digits in base. *)
   Definition valid_prefix_len (base : Z) (s : list Z) : Z := ...

   (* Value of a list of digits, most significant first:
      digits_to_Z base [d1; d2; d3] = (d1 * base + d2) * base + d3 *)
   Definition digits_to_Z (base : Z) (ds : list Z) : Z := ...

   Lemma digits_to_Z_app : forall base ds d,
     digits_to_Z base (ds ++ [d]) = base * digits_to_Z base ds + d.
*)
