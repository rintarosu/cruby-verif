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

(* Value of a list of digits, most significant first:
   digits_to_Z base [d1; d2; d3] = (d1 * base + d2) * base + d3.
   This is the mathematical (unbounded) value that the loop computes with
   ret = ret * base + d. *)
Definition digits_to_Z (base : Z) (ds : list Z) : Z :=
  fold_left (fun acc d => acc * base + d) ds 0.

Lemma digits_to_Z_nil : forall base,
  digits_to_Z base [] = 0.
Proof. reflexivity. Qed.

Lemma digits_to_Z_app : forall base ds d,
  digits_to_Z base (ds ++ [d]) = base * digits_to_Z base ds + d.
Proof.
  intros. unfold digits_to_Z. rewrite fold_left_app. simpl. ring.
Qed.

(* Number of leading characters of s that are valid digits in base. *)
Fixpoint valid_prefix_len (base : Z) (s : list Z) : Z :=
  match s with
  | [] => 0
  | c :: s' =>
      let d := digit_value c in
      if andb (0 <=? d) (d <? base) then 1 + valid_prefix_len base s' else 0
  end.

(* What ruby_scan_digits returns, for 0 <= len (scan at most len characters). *)

(* Number of characters read: *retlen. *)
Definition scan_len (base len : Z) (s : list Z) : Z :=
  Z.min len (valid_prefix_len base s).

(* Value of the first i characters of s. The loop keeps ret = this mod 2^64. *)
Definition prefix_value (base : Z) (s : list Z) (i : Z) : Z :=
  digits_to_Z base (map digit_value (sublist 0 i s)).

(* Contents of *overflow for a mathematical value v. *)
Definition overflow_flag (v : Z) : Z := if v <? Int64.modulus then 0 else 1.

(* Mathematical (unbounded) value of the digits read. The C function returns
   this modulo 2^64, and sets *overflow iff it is at least 2^64. *)
Definition scan_value (base len : Z) (s : list Z) : Z :=
  prefix_value base s (scan_len base len s).
