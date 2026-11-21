# Local development environment for cruby-verif.
#
# The official rocq/rocq-prover images used in CI are amd64 only, so this
# image starts from ocaml/opam (multi-arch) to run natively on Apple Silicon.
# Package versions follow cruby-verif.opam, which CI also uses.
FROM ocaml/opam:debian-12-ocaml-4.14

ARG ROCQ_VERSION=9.1.1

RUN opam repo add rocq-released https://rocq-prover.org/opam/released \
 && opam update \
 && opam install -y --confirm-level=unsafe-yes "coq.${ROCQ_VERSION}" dune

COPY --chown=opam:opam cruby-verif.opam /tmp/deps/
RUN opam install -y --confirm-level=unsafe-yes --deps-only /tmp/deps/cruby-verif.opam \
 && opam clean -a -c -s --logs

WORKDIR /work
CMD ["bash"]
