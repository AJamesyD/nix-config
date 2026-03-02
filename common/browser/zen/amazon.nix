# Amazon-specific Zen Browser config.
# Import only on work machines (alongside common/aws.nix).
#
# Extensions to install manually:
#   - Isengard ({399ddce7-bc6d-4d7b-b085-148765d621b2})
#   - Amazon Enterprise Access (amazon_enterprise_access@amazon)
#   - Containerize AWS Console (contain-aws-console@amazon.com)
_: {
  programs.zen-browser.profiles.default.settings = {
    "privacy.userContext.extension" = "contain-aws-console@amazon.com";
    # NOTE: allows unsigned extensions (needed for Amazon internal extensions)
    "xpinstall.signatures.required" = false;
  };
}
