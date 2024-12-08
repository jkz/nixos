{
  "@home" = {
    pkgs,
    flake-inputs,
    ...
  }: {
    programs.emacs = {
      enable = true;
      extraPackages = e: let
        callPackage = pkgs.lib.callPackageWith (pkgs // e);
      in with e; [
        general
        magit
        buffer-move
        which-key
        gruvbox-theme
        vertico
        # savehist
        emacs
        marginalia
        projectile
        treemacs
        treemacs-projectile
        treemacs-magit
        treemacs-persp
        rainbow-delimiters
        undo-tree
        python
        company
        flycheck
        typescript-mode
        tide
        perspective
        persp-projectile
        editorconfig
        svelte-mode

        llm
        (callPackage flake-inputs.org-llm.emacsPackages.default {})
      ];
    };
  };
}