# Atualiza somente user/default e boot/systemd; preserva as demais configuracoes.
function finish_section() {
    if (section == "user" && !has_default) { print "default=" username; has_default=1 }
    if (section == "boot" && !has_systemd) { print "systemd=true"; has_systemd=1 }
}
{
    sub(/\r$/, "")
    if ($0 ~ /^[ \t]*\[/) {
        finish_section()
        section=$0
        sub(/^[ \t]*\[/, "", section)
        sub(/\].*$/, "", section)
        section=tolower(section)
        if (section == "user") user_seen=1
        if (section == "boot") boot_seen=1
    }
    if (section == "user" && $0 ~ /^[ \t]*default[ \t]*=/) {
        if (!has_default) print "default=" username
        has_default=1
        next
    }
    if (section == "boot" && $0 ~ /^[ \t]*systemd[ \t]*=/) {
        if (!has_systemd) print "systemd=true"
        has_systemd=1
        next
    }
    print
}
END {
    finish_section()
    if (!user_seen) print "\n[user]\ndefault=" username
    if (!boot_seen) print "\n[boot]\nsystemd=true"
}
