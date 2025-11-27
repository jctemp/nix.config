# ===============================================================
#       USER WORKER SHARED CONFIGURATION
# ===============================================================
{
  userName = "worker";

  # ===============================================================
  #       SECURITY
  # ===============================================================
  # Generate with: mkpasswd -m yescrypt
  hashedPassword = "$y$j9T$P1wQbX0khrRAvpumtW12D1$pOke0FO.seDfeJoViRwXWkvH32ZuNJEE.9fAoLPCxN7";

  # ===============================================================
  #       SSH KEYS
  # ===============================================================
  authorizedKeys = [
    # TODO: new management intended with yubikey and SecOPS
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaKUw7XbzrROfMEWUjohK01FzVNZrMBWtuLvDPCz323H6i9+9Q+KqkcVGyVoaUED8v3X/YGQaPqieugJjAOtech64tbeuYi00iFSaV+sJhJ7/bY+tg1QX46GwieKy4myhvTHFnwDTP6FG73MPomVjErbNOHRb8NueNFYEmGD+XJBrjFFFONTI1/EEdT+TNVG8rg75tYowgCGaKUmUE+rpzi2EcuVbBYCaHFcBvSrwCxf3NwtnxTZJ01z378vzYgKV+atbidsujG/WYSANWiH6h0JPbnbtIRnMVoPibGGVZZMXhasWdC4TuGQMLlPzx9it3n6VthOAIJMMQG3ImBg43lYSQcyv07vWtrfU3DT3QC6DvudLPDDsqRz3R9lVn2nRlc5BRVXgJnolJjensK53a3drtAapCLlCW4njDi/AYcHB2xIFzsgr88gO+fODek0v6v6OG7q9L1EpVY4+UbNbQW8zc/SxQNZ3t2zV1v5aCU+q6G0hj3JPQoCDJCNHsDfrtrP46HO9XUOErK9FYd1Ry4ClMmhK/4fewj8BrGSG8cbL8rfFSVqQQx8s7Bera+z+2yHmLgxvC9a5y3MbeWvRB3PP2gEzc5kku0eDyhBX8DZRm5facML/eHGqZcVwMqeyHph+OxplpbyBpW+Y8ehYpyDPHaMLw85EzvhA/tB80SQ== openpgp:0x4C957822"
  ];
}
