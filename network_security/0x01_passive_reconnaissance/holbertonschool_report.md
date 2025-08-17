# Holberton School Passive Reconnaissance Report

## 1. Overview
This report summarizes the information gathered about the domain **holbertonschool.com** using Shodan. The goal was to collect IP ranges, technologies, and frameworks used across all subdomains.

---

## 2. IP Addresses and Hostnames
| IP Address     | Hostname                                         | Organization              | Location         | Product/Service       | Timestamp                  |
|---------------|-------------------------------------------------|--------------------------|----------------|--------------------|---------------------------|
| 52.47.143.83  | ec2-52-47-143-83.eu-west-3.compute.amazonaws.com | Amazon Data Services France | Paris, France  | cloudeol-product     | 2025-08-14T20:47:07.606884 |
| 35.180.27.154 | ec2-35-180-27-154.eu-west-3.compute.amazonaws.com | Amazon Data Services France | Paris, France  | cloudeol-product     | 2025-08-13T19:36:29.932282 |
| 35.180.27.154 | ec2-35-180-27-154.eu-west-3.compute.amazonaws.com | Amazon Data Services France | Paris, France  | cloudeol-product     | 2025-07-23T23:20:39.110691 |

---

## 3. HTTP Information
- Most responses returned **301 Moved Permanently**.
- Web servers observed:
  - `nginx/1.21.6`
  - `nginx/1.18.0 (Ubuntu)`
- Example locations:
  - `https://yriry2.holbertonschool.com/`
  - `http://holbertonschool.com`

---

## 4. Top Ports
| Port | Occurrences |
|------|------------|
| 80   | 2          |
| 443  | 1          |

---

## 5. Notes
- Holberton School is hosted on **Amazon AWS EC2 instances** in Paris, France.
- Uses **nginx web servers** with Ubuntu on some hosts.
- Multiple subdomains redirect using HTTP 301 responses.
- Product Spotlight: They launched a new API for fast vulnerability lookups (CVEDB).


