# LAPORAN PROJEK I DEFENDER — DKM FORMAT

---

## ABSTRAK

&nbsp;&nbsp;&nbsp;&nbsp;Projek ini bertajuk **I Defender** merupakan satu sistem keselamatan dan pemantauan rangkaian komputer yang dibangunkan menggunakan papan litar tunggal *Raspberry Pi 4 Model B* berkuasa *8GB RAM*. Sistem ini direka untuk mengesan dan memantau ancaman siber dalam persekitaran rangkaian kawasan setempat (*Local Area Network* / LAN) bagi organisasi kecil, sekolah dan institusi yang mempunyai bajet terhad. I Defender menggunakan perisian pengesanan pencerobohan *Snort* yang dikonfigurasikan pada sistem operasi *Raspberry Pi OS 64-bit*, dengan sokongan *iptables* sebagai dinding api (*firewall*) bagi mengawal lalu lintas rangkaian masuk dan keluar.

&nbsp;&nbsp;&nbsp;&nbsp;Metodologi pembangunan projek ini menggunakan Model Air Terjun (*Waterfall Model*) yang merangkumi fasa perancangan, analisis, rekabentuk, implementasi dan pengujian. Perkakasan utama yang digunakan ialah *Raspberry Pi 4 Model B 8GB*, kad *MicroSD 64GB*, kabel *Ethernet*, *switch* rangkaian dan bekalan kuasa *USB-C*. Perisian yang digunakan pula ialah *Raspberry Pi OS 64-bit*, *Snort 3*, *iptables*, *Wireshark* dan *Squil* sebagai antaramuka pemantauan.

&nbsp;&nbsp;&nbsp;&nbsp;Hasil projek membuktikan bahawa sistem I Defender yang berasaskan *Raspberry Pi 4* berjaya mengesan pelbagai serangan rangkaian termasuk *port scanning*, *brute force* dan *Denial of Service* (*DoS*) dalam persekitaran makmal yang terkawal. Kos pembangunan keseluruhan sistem ini jauh lebih rendah berbanding penyelesaian keselamatan rangkaian komersial. Kesimpulannya, I Defender merupakan penyelesaian keselamatan rangkaian yang praktikal, kos efektif dan berkesan untuk kegunaan institusi kecil dan sederhana.

---

## BAB I

## PENGENALAN

---

### 1.1 PENGENALAN PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Projek I Defender merupakan sebuah sistem pertahanan dan pemantauan keselamatan rangkaian komputer yang dibangunkan di atas platform *Raspberry Pi 4 Model B 8GB RAM*. Nama "I Defender" merujuk kepada *Internet Defender*, iaitu satu konsep sistem yang bertindak sebagai barisan pertahanan pertama (*first line of defense*) terhadap serangan yang datang melalui rangkaian internet mahupun rangkaian kawasan setempat (*Local Area Network* / LAN). Pemilihan *Raspberry Pi 4* sebagai platform utama adalah berdasarkan faktor kos yang rendah, saiz yang padat, penggunaan kuasa yang cekap serta keupayaan pemprosesan yang mencukupi untuk menjalankan perisian keselamatan rangkaian secara berterusan.

&nbsp;&nbsp;&nbsp;&nbsp;Ancaman keselamatan siber semakin meningkat dalam kalangan organisasi kecil yang tidak mempunyai peruntukan kewangan yang besar untuk melabur dalam sistem keselamatan rangkaian bertaraf komersial. Projek I Defender dibangunkan sebagai alternatif yang mampu milik dengan memanfaatkan perisian *open-source* yang terbukti berkesan dan perkakasan yang mudah diperolehi di pasaran tempatan. Jangkaan hasil bagi projek ini ialah sebuah sistem pengesan pencerobohan rangkaian yang berfungsi sepenuhnya, dapat dipasang dengan kos kurang daripada RM 300, dan mampu dikendalikan oleh pentadbir rangkaian yang mempunyai kemahiran asas Linux.

---

### 1.2 LATARBELAKANG MASALAH

&nbsp;&nbsp;&nbsp;&nbsp;Peningkatan penggunaan internet dan rangkaian komputer dalam pelbagai sektor telah membawa kepada peningkatan ancaman keselamatan siber yang berlaku setiap hari. Berdasarkan laporan *CyberSecurity Malaysia* tahun 2023, insiden siber yang dilaporkan di Malaysia terus meningkat setiap tahun, dengan organisasi kecil dan institusi pendidikan menjadi antara sasaran utama penceroboh rangkaian. Kebanyakan insiden ini berlaku kerana kekurangan sistem pemantauan rangkaian yang aktif dan berterusan.

&nbsp;&nbsp;&nbsp;&nbsp;Melalui pemerhatian dan kajian yang dijalankan, beberapa masalah utama telah dikenal pasti. Pertama, kebanyakan organisasi kecil hanya bergantung kepada perisian antivirus biasa yang tidak mampu mengesan ancaman yang berlaku pada peringkat rangkaian. Kedua, penyelesaian keselamatan rangkaian komersial seperti *Cisco IDS* dan *Fortinet* memerlukan kos yang sangat tinggi, menjadikannya di luar kemampuan organisasi kecil dan institusi pendidikan. Ketiga, ketiadaan sistem pemantauan dan amaran masa nyata menyebabkan pentadbir rangkaian hanya menyedari serangan setelah kerosakan atau kehilangan data berlaku. Keempat, konfigurasi keselamatan rangkaian yang lemah seperti kata laluan lalai (*default password*) dan port yang terbuka tanpa kawalan turut menjadi faktor kelemahan yang dieksploitasi oleh penceroboh.

&nbsp;&nbsp;&nbsp;&nbsp;Berdasarkan masalah-masalah yang dikenal pasti ini, wujud keperluan mendesak untuk membangunkan satu sistem keselamatan rangkaian yang berkesan, mudah digunakan dan mampu milik. Projek I Defender hadir sebagai penyelesaian kepada jurang ini dengan memanfaatkan perkakasan *Raspberry Pi 4* yang berharga rendah dan perisian *open-source* yang berkualiti tinggi bagi membentuk satu sistem pengesanan pencerobohan yang berfungsi sepenuhnya.

---

### 1.3 OBJEKTIF PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Objektif kajian adalah seperti berikut:

i) Membangunkan sistem pengesanan pencerobohan rangkaian (*Intrusion Detection System* / IDS) berasaskan *Raspberry Pi 4 Model B 8GB* yang mampu mengesan ancaman rangkaian seperti *port scanning*, *brute force* dan serangan *Denial of Service* (*DoS*) secara masa nyata.

ii) Mengkonfigurasi perisian *Snort 3* dan *iptables* pada sistem operasi *Raspberry Pi OS 64-bit* bagi membentuk sistem keselamatan rangkaian yang berfungsi sebagai pengesan dan penghalang ancaman dalam persekitaran rangkaian *LAN*.

iii) Menyediakan antaramuka pemantauan log dan amaran (*alert*) yang membolehkan pentadbir rangkaian memantau aktiviti rangkaian, menyemak rekod serangan dan mengurus peraturan (*rules*) keselamatan dengan mudah melalui antara muka berasaskan teks mahupun web.

---

### 1.4 SKOP PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Bagi mencapai matlamat dan objektif yang digariskan, beberapa skop projek telah dikenalpasti.

&nbsp;&nbsp;&nbsp;&nbsp;Antaranya ialah:

i. Projek ini meliputi pembangunan, konfigurasi dan pengujian sistem I Defender dalam persekitaran rangkaian *LAN* yang terhad kepada satu segmen rangkaian dengan maksimum 30 peranti yang disambungkan menggunakan *switch* 24-port.

ii. Batasan dari segi lokasi kajian adalah tertumpu kepada persekitaran makmal komputer di E-Access International College sahaja dan tidak merangkumi implementasi di lokasi luar atau persekitaran rangkaian yang sebenar.

iii. Batasan dari segi tempoh adalah selama empat (4) bulan, bermula dari bulan Januari hingga April, yang merangkumi keseluruhan fasa perancangan, pembangunan, pengujian dan dokumentasi projek.

iv. Sistem I Defender hanya menyokong pemantauan trafik rangkaian berwayar (*wired*) menggunakan protokol *IPv4* dan tidak merangkumi pemantauan ke atas rangkaian tanpa wayar (*wireless*) atau protokol *IPv6*.

v. Pengujian sistem dijalankan menggunakan senario serangan simulasi (*simulated attack scenario*) di dalam persekitaran makmal yang terkawal sepenuhnya dan tidak melibatkan sebarang pengujian ke atas rangkaian atau sistem yang sebenar.

---

## BAB II

## METODOLOGI

---

### 2.1 PENGENALAN

&nbsp;&nbsp;&nbsp;&nbsp;Bab ini akan menerangkan kaedah-kaedah yang digunakan dan aliran perjalanan projek I Defender bagi pelaksanaan projek secara menyeluruh. Penerangan akan merangkumi susun atur (*set-up*) perkakasan dan perisian bagi projek berkenaan, langkah-langkah pelaksanaan setiap fasa, serta langkah-langkah pengubahsuaian (*troubleshooting*) yang diambil untuk memastikan sistem berfungsi dengan lancar. Metodologi yang dipilih adalah bersesuaian dengan sifat projek yang bersifat teknikal dan memerlukan pengujian yang teliti sebelum sistem dapat diisytiharkan berfungsi sepenuhnya.

---

### 2.2 SUSUN ATUR PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Projek ini menggunakan **Model Air Terjun (*Waterfall Model*)** sebagai rangka kerja pembangunan utama. Pendekatan ini sesuai digunakan kerana keperluan sistem projek I Defender telah dikenal pasti dengan jelas dari awal, membolehkan setiap fasa dilaksanakan secara berurutan dan teratur. Bahagian ini menerangkan secara terperinci setiap fasa pelaksanaan projek, keperluan perkakasan dan perisian yang digunakan.

**Fasa 1: Perancangan (*Planning*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pada fasa ini, skop projek, matlamat, keperluan perkakasan dan perisian, serta jadual pelaksanaan ditetapkan. Sesi perbincangan bersama penyelia projek dijalankan bagi mendapatkan panduan dan hala tuju yang jelas. Kajian literatur berkaitan sistem keselamatan rangkaian, *Intrusion Detection System* dan keupayaan *Raspberry Pi 4* sebagai pelayan (*server*) turut dijalankan. Carta Gantt disediakan bagi memastikan setiap fasa dilaksanakan mengikut tempoh yang telah ditetapkan.

**Fasa 2: Analisis Sistem (*System Analysis*)**

&nbsp;&nbsp;&nbsp;&nbsp;Fasa analisis melibatkan kajian mendalam terhadap jenis-jenis ancaman rangkaian yang lazim berlaku dalam persekitaran *LAN*. Kajian perbandingan antara pelbagai perisian *IDS open-source* seperti *Snort*, *Suricata* dan *Zeek* dijalankan dari segi keupayaan pengesanan, penggunaan sumber (*resource usage*) dan keserasian dengan seni bina *ARM64* milik *Raspberry Pi 4*. Hasil analisis mendapati *Snort 3* adalah pilihan terbaik kerana menyokong seni bina *ARM64*, penggunaan memori yang cekap dan mempunyai dokumentasi yang lengkap.

**Fasa 3: Rekabentuk Sistem (*System Design*)**

&nbsp;&nbsp;&nbsp;&nbsp;Rekabentuk sistem I Defender merangkumi rekabentuk senibina rangkaian (*network architecture*), rekabentuk topologi fizikal dan rekabentuk konfigurasi perisian. *Raspberry Pi 4* ditempatkan di antara *router* utama dan *switch* rangkaian dalam konfigurasi *inline* atau *tap* bagi membolehkan semua trafik rangkaian dipantau. Sistem operasi *Raspberry Pi OS 64-bit* dipilih sebagai asas kerana menyokong sepenuhnya semua perisian yang diperlukan dan dioptimumkan untuk perkakasan *Raspberry Pi 4*.

**Fasa 4: Implementasi (*Implementation*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pada fasa ini, semua komponen sistem dipasang dan dikonfigurasi mengikut rekabentuk yang telah dipersetujui. Proses implementasi meliputi pemasangan sistem operasi *Raspberry Pi OS 64-bit (Bookworm)* pada kad *MicroSD 64GB*, konfigurasi rangkaian dengan dua antara muka (*dual NIC*) menggunakan penyesuai *Ethernet USB 3.0* tambahan, pemasangan dan konfigurasi *Snort 3* dengan set peraturan (*community ruleset*) terkini, konfigurasi *iptables* sebagai dinding api, serta pemasangan *Wireshark* untuk analisis paket rangkaian.

**Fasa 5: Pengujian (*Testing*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pengujian sistem dijalankan menggunakan alat *Nmap* untuk simulasi *port scanning*, *hping3* untuk simulasi serangan *DoS*, dan percubaan log masuk berulang (*brute force*) menggunakan *Hydra* daripada sebuah komputer penyerang yang berasingan dalam rangkaian makmal yang terkawal. Semua amaran yang dijana oleh *Snort* direkodkan dan disemak untuk mengesahkan keberkesan sistem pengesanan.

**Keperluan Perkakasan:**

| Bil | Perkakasan | Spesifikasi | Kuantiti |
|-----|-----------|-------------|---------|
| 1 | Raspberry Pi 4 Model B | 8GB RAM, ARM Cortex-A72 1.8GHz | 1 unit |
| 2 | Kad MicroSD | 64GB, Kelas 10 / A2 | 1 keping |
| 3 | Penyesuai Ethernet USB 3.0 | Gigabit, untuk antara muka kedua | 1 unit |
| 4 | Bekalan Kuasa USB-C | 5V / 3A | 1 unit |
| 5 | Switch Rangkaian | 24-port, 100Mbps | 1 unit |
| 6 | Kabel Ethernet Cat5e | Pelbagai panjang | 5 utas |
| 7 | Komputer Pengguna | Standard PC | 5 unit |
| 8 | Komputer Penyerang (Ujian) | Standard PC, Kali Linux | 1 unit |

**Keperluan Perisian:**

| Bil | Perisian | Versi | Fungsi |
|-----|---------|-------|--------|
| 1 | Raspberry Pi OS 64-bit | Bookworm (Debian 12) | Sistem Operasi Utama |
| 2 | Snort 3 | 3.1.x | Pengesanan Pencerobohan (IDS) |
| 3 | iptables | 1.8.x | Dinding Api (*Firewall*) |
| 4 | Wireshark | 4.x | Analisis Trafik Rangkaian |
| 5 | Squil / Sguil | Terkini | Antaramuka Pemantauan Log |
| 6 | Kali Linux | 2024.x | Sistem Operasi Komputer Ujian |

---

### KESIMPULAN

&nbsp;&nbsp;&nbsp;&nbsp;Secara keseluruhannya, Bab II ini telah menerangkan dengan terperinci metodologi dan susun atur yang digunakan dalam pembangunan projek I Defender. Pemilihan *Raspberry Pi 4 Model B 8GB* sebagai platform utama terbukti mampu menjalankan perisian pengesanan pencerobohan *Snort 3* dengan prestasi yang memuaskan tanpa memerlukan perkakasan pelayan (*server*) bertaraf tinggi yang berharga mahal. Penggunaan Model Air Terjun (*Waterfall Model*) pula memastikan setiap fasa daripada perancangan sehinggalah pengujian dilaksanakan secara sistematik dan teratur.

&nbsp;&nbsp;&nbsp;&nbsp;Susun atur projek yang telah dirancang dengan teliti, pemilihan perisian *open-source* yang sesuai dengan seni bina *ARM64* milik *Raspberry Pi 4*, serta prosedur pengujian yang komprehensif merupakan faktor utama yang menyumbang kepada kelancaran pembangunan sistem I Defender. Dengan konfigurasi perkakasan dan perisian yang telah dilaksanakan, sistem ini sedia untuk menjalani fasa penilaian dan analisis hasil yang akan dibincangkan dengan lebih lanjut dalam bab seterusnya.

---

*[Nota Format DKM: Times New Roman Saiz 12, 1.5 Spacing, Justified, Tab 1 kali awal perenggan, Margin Kiri 1.25" Kanan 1.0" Atas Bawah 1.0", Header & Footer 0.5"]*
