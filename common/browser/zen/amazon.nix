# Amazon-specific Zen Browser config.
# Import only on work machines (alongside common/aws.nix).
#
# Extensions to install manually:
#   - Isengard ({399ddce7-bc6d-4d7b-b085-148765d621b2})
#   - Amazon Enterprise Access (amazon_enterprise_access@amazon)
#   - Containerize AWS Console (contain-aws-console@amazon.com)
{ lib, ... }:
let
  zenProfile = "Library/Application Support/Zen/Profiles/default";
  baseHandlers = builtins.fromJSON (builtins.readFile ./handlers.json);
in
{
  programs.zen-browser.profiles.default.settings = {
    "privacy.userContext.extension" = "contain-aws-console@amazon.com";
    # NOTE: allows unsigned extensions (needed for Amazon internal extensions)
    "xpinstall.signatures.required" = false;
  };

  home.file."${zenProfile}/handlers.json".text = builtins.toJSON (
    lib.recursiveUpdate baseHandlers {
      schemes = {
        acme = {
          action = 4;
        };
        mailto = baseHandlers.schemes.mailto // {
          handlers = baseHandlers.schemes.mailto.handlers ++ [
            {
              name = "outlook.office.com";
              uriTemplate = "https://outlook.office.com/mail/angaidan@amazon.mail.onmicrosoft.com/deeplink/compose?mailtouri=%s";
            }
          ];
        };
      };
    }
  );
}
