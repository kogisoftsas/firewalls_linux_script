#!/bin/bash

# Limpiar reglas anteriores
iptables -F
iptables -X
iptables -Z

# Políticas por defecto: todo bloqueado
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Interfaces:
# - eth1 = IP pública: 139.177.202.85
# - tailscale0 = IP privada segura: 100.89.25.54

# ----------------------------------------
# 🟢 Permitir tráfico interno básico
# ----------------------------------------

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ----------------------------------------
# 🟢 Permitir TODO el tráfico Tailscale
# ----------------------------------------

iptables -A INPUT -i tailscale0 -j ACCEPT
iptables -A OUTPUT -o tailscale0 -j ACCEPT

# ----------------------------------------
# 🟢 SSH solo desde IPs de ingeniería por Tailscale
# ----------------------------------------

iptables -A INPUT -p tcp -s 100.99.47.106 --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -s 100.76.34.16 --dport 22 -j ACCEPT

iptables -A OUTPUT -p tcp --sport 22 -d 100.99.47.106 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 100.76.34.16 -j ACCEPT

# ----------------------------------------
# 🟢 Permitir acceso completo a proveedor (no limitado a ningún puerto)
# ----------------------------------------

iptables -A INPUT -s 45.33.98.206 -j ACCEPT
iptables -A OUTPUT -d 45.33.98.206 -j ACCEPT

# ----------------------------------------
# 🟢 Permitir comunicación interna entre IP pública y Tailscale local
# (necesario para que tailscale funcione correctamente)
# ----------------------------------------

iptables -A INPUT -i eth1 -s 139.177.202.85 -d 100.89.25.54 -j ACCEPT
iptables -A OUTPUT -o eth1 -s 139.177.202.85 -d 100.89.25.54 -j ACCEPT
