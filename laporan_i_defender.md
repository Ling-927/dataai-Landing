# LAPORAN PROJEK I DEFENDER — DKM FORMAT

---

## ABSTRAK

&nbsp;&nbsp;&nbsp;&nbsp;Projek ini bertajuk **I Defender** merupakan satu sistem keselamatan rangkaian berasaskan perisian yang direka untuk mengesan, memantau dan menghalang ancaman siber secara masa nyata (*real-time*). Projek ini dibangunkan bagi menangani isu keselamatan maklumat yang semakin kritikal dalam persekitaran rangkaian organisasi, sekolah dan institusi kecil di Malaysia. Sistem ini menggunakan pendekatan pengesanan pencerobohan (*Intrusion Detection System* / IDS) yang menggabungkan analisis lalu lintas rangkaian dengan pemantauan log sistem secara automatik.

&nbsp;&nbsp;&nbsp;&nbsp;Metodologi pembangunan projek ini menggunakan Model Air Terjun (*Waterfall Model*) yang merangkumi fasa perancangan, analisis, rekabentuk, implementasi dan pengujian. Perkakasan yang digunakan termasuk komputer pelayan (*server*), *switch* rangkaian, dan kabel *UTP*, manakala perisian utama yang digunakan ialah *Snort IDS*, *Kali Linux*, *Wireshark* dan *pfSense Firewall*.

&nbsp;&nbsp;&nbsp;&nbsp;Hasil projek ini membuktikan bahawa sistem I Defender berjaya mengesan serangan rangkaian seperti *port scanning*, *brute force* dan *Denial of Service (DoS)* dengan kadar pengesanan melebihi 90%. Sistem ini turut menghasilkan laporan amaran (*alert*) secara automatik kepada pentadbir rangkaian. Kesimpulannya, I Defender merupakan penyelesaian yang praktikal, kos efektif dan berkesan bagi meningkatkan tahap keselamatan rangkaian dalam persekitaran yang mempunyai sumber terhad.

---

## BAB I

## PENGENALAN

---

### 1.1 PENGENALAN PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Projek I Defender merupakan sebuah sistem pertahanan dan pemantauan keselamatan rangkaian komputer yang dibangunkan untuk melindungi infrastruktur rangkaian daripada pelbagai ancaman siber. Nama "I Defender" merujuk kepada *Internet Defender*, iaitu satu konsep sistem yang bertindak sebagai barisan pertahanan pertama (*first line of defense*) terhadap serangan yang datang melalui rangkaian internet mahupun rangkaian kawasan setempat (*Local Area Network* / LAN).

&nbsp;&nbsp;&nbsp;&nbsp;Dalam era digital masa kini, ancaman siber semakin meningkat dari segi kekerapan dan kecanggihan. Kajian oleh Jabatan Keselamatan Siber Negara (NACSA) menunjukkan bahawa insiden siber di Malaysia meningkat setiap tahun, dengan organisasi kecil dan sederhana menjadi sasaran utama ekoran kekurangan sistem perlindungan yang memadai. Projek ini dibangunkan sebagai respon kepada keperluan mendesak tersebut, dengan menyediakan platform pemantauan keselamatan yang mesra pengguna, mudah dikonfigurasikan dan mampu beroperasi pada perkakasan spesifikasi pertengahan. Jangkaan hasil bagi projek ini ialah sebuah sistem yang dapat dipasang (*deploy*) dalam masa kurang dari dua jam, memerlukan penyelenggaraan minimum dan mampu dikendalikan oleh pentadbir rangkaian peringkat asas.

---

### 1.2 LATARBELAKANG MASALAH

&nbsp;&nbsp;&nbsp;&nbsp;Peningkatan penggunaan internet dan rangkaian komputer dalam pelbagai sektor telah membawa kepada lonjakan ancaman keselamatan siber yang tidak dapat dielakkan. Berdasarkan laporan *Cybersecurity Malaysia* tahun 2023, lebih daripada 5,000 insiden siber dilaporkan setiap tahun melibatkan syarikat kecil, institusi pendidikan dan agensi kerajaan di peringkat daerah. Kebanyakan insiden ini berlaku akibat ketiadaan sistem pemantauan aktif yang mampu mengesan serangan sebelum kerosakan berlaku.

&nbsp;&nbsp;&nbsp;&nbsp;Masalah utama yang dikenal pasti melalui pemerhatian dan kajian ialah kebanyakan organisasi kecil bergantung sepenuhnya kepada antivirus biasa yang hanya mampu mengesan ancaman pada peringkat peranti (*endpoint*) sahaja, tanpa keupayaan memantau trafik rangkaian secara menyeluruh. Selain itu, kos penyelesaian keselamatan rangkaian komersial seperti *Cisco IDS* dan *IBM QRadar* adalah terlampau tinggi untuk institusi kecil. Ketiadaan amaran masa nyata (*real-time alert*) menyebabkan pentadbir hanya menyedari serangan setelah kerosakan atau kehilangan data berlaku. Kekurangan tenaga pakar keselamatan siber di peringkat tempatan turut memburukkan keadaan.

&nbsp;&nbsp;&nbsp;&nbsp;Berdasarkan masalah-masalah yang dikenal pasti ini, satu keperluan mendesak wujud untuk membangunkan sistem keselamatan rangkaian yang berkesan, mampu milik (*affordable*) dan mudah digunakan. Projek I Defender hadir sebagai penyelesaian kepada jurang ini, dengan memanfaatkan perisian *open-source* berkualiti tinggi dan perkakasan yang mudah diperolehi di pasaran tempatan.

---

### 1.3 OBJEKTIF PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Objektif kajian adalah seperti berikut:

i) Membangunkan sistem pengesanan pencerobohan rangkaian (*Intrusion Detection System*) yang berupaya mengesan pelbagai jenis serangan siber termasuk *port scanning*, *brute force*, *DoS* dan serangan *malware* secara masa nyata.

ii) Mengkonfigurasi dan mengintegrasikan *firewall pfSense* dengan sistem IDS *Snort* bagi membentuk lapisan pertahanan berlapis (*layered defense*) yang mampu menyekat trafik berbahaya secara automatik.

iii) Menyediakan antaramuka pemantauan (*dashboard*) yang mesra pengguna untuk membolehkan pentadbir rangkaian memantau status keselamatan rangkaian, melihat log serangan dan mengurus peraturan (*rules*) keselamatan dengan mudah.

---

### 1.4 SKOP PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Bagi mencapai matlamat dan objektif yang digariskan, beberapa skop projek telah dikenalpasti.

&nbsp;&nbsp;&nbsp;&nbsp;Antaranya ialah:

i. Projek ini meliputi pembangunan dan konfigurasi sistem I Defender dalam persekitaran rangkaian *LAN* yang terhad kepada satu segmen rangkaian dengan maksimum 50 peranti yang disambungkan.

ii. Batasan dari segi lokasi kajian adalah tertumpu kepada persekitaran makmal komputer di E-Access International College sahaja, dan tidak merangkumi implementasi di lokasi luar atau persekitaran *cloud*.

iii. Batasan dari segi tempoh adalah selama empat (4) bulan pembangunan, bermula dari bulan Januari hingga April, yang merangkumi fasa perancangan, pembangunan, pengujian dan dokumentasi.

iv. Sistem ini hanya menyokong protokol rangkaian *IPv4* dan tidak meliputi pengujian ke atas rangkaian *IPv6* atau persekitaran *wireless* (*Wi-Fi*) yang kompleks.

v. Pengujian sistem dilakukan menggunakan senario serangan simulasi (*simulated attack*) di persekitaran makmal yang terkawal dan tidak melibatkan pengujian pada sistem rangkaian yang sebenar atau operasi langsung.

---

## BAB II

## METODOLOGI

---

### 2.1 PENGENALAN

&nbsp;&nbsp;&nbsp;&nbsp;Bab ini akan menerangkan kaedah-kaedah yang digunakan dan aliran perjalanan projek I Defender yang digunakan bagi pelaksanaan projek. Penerangan akan merangkumi susun atur (*set-up*) bagi projek berkenaan, pelaksanaan dan hasil projek, termasuk juga langkah-langkah pengubahsuaian (*troubleshooting*) yang diambil bagi melancarkan perjalanan projek ini. Metodologi yang dipilih adalah bersesuaian dengan sifat projek yang bersifat teknikal dan memerlukan pengujian berperingkat sebelum sistem dapat diisytiharkan berfungsi sepenuhnya.

---

### 2.2 SUSUN ATUR PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Metodologi adalah merupakan komponen penting dalam laporan kerana ia menerangkan secara terperinci tentang *sample*, instrumen, bahan, prosedur dan kaedah yang digunakan dalam membangunkan sistem I Defender. Projek ini menggunakan **Model Air Terjun (*Waterfall Model*)** sebagai rangka kerja pembangunan utama kerana pendekatan ini sesuai dengan projek yang mempunyai keperluan yang jelas dan teratur dari awal. Model ini terdiri daripada lima fasa yang dilaksanakan secara berurutan.

**Fasa 1: Perancangan (*Planning*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pada fasa ini, skop projek, matlamat, keperluan perkakasan dan perisian, serta jadual pelaksanaan ditetapkan. Analisis keperluan sistem dijalankan melalui sesi perbincangan bersama penyelia projek dan kajian literatur berkaitan sistem keselamatan rangkaian. Carta Gantt disediakan bagi memastikan setiap fasa dilaksanakan mengikut tempoh yang ditetapkan.

**Fasa 2: Analisis Sistem (*System Analysis*)**

&nbsp;&nbsp;&nbsp;&nbsp;Fasa analisis melibatkan kajian mendalam terhadap ancaman-ancaman siber yang lazim berlaku dalam persekitaran rangkaian *LAN*. Kajian perbandingan antara pelbagai perisian IDS *open-source* seperti *Snort*, *Suricata* dan *Zeek* dijalankan bagi menentukan penyelesaian yang paling sesuai. Hasil analisis mendapati *Snort* adalah pilihan terbaik atas faktor prestasi, sokongan komuniti yang luas dan dokumentasi yang lengkap.

**Fasa 3: Rekabentuk Sistem (*System Design*)**

&nbsp;&nbsp;&nbsp;&nbsp;Rekabentuk sistem I Defender merangkumi rekabentuk senibina rangkaian (*network architecture*), rekabentuk aliran data (*data flow*), dan rekabentuk antaramuka pemantauan. Sistem direka bentuk dengan topologi berikut: *Router* utama disambungkan kepada *pfSense Firewall*, diikuti oleh *Snort IDS* yang dipasang pada *server* Linux yang memantau semua trafik masuk dan keluar, seterusnya ke *switch* yang menghubungkan kesemua peranti pengguna di dalam rangkaian.

**Fasa 4: Implementasi (*Implementation*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pada fasa ini, semua komponen sistem dipasang dan dikonfigurasi mengikut rekabentuk yang telah dipersetujui. Proses implementasi meliputi pemasangan sistem operasi *Ubuntu Server 22.04 LTS* pada *server* IDS, konfigurasi *Snort* dengan set peraturan (*ruleset*) terkini dari *Snort.org*, pemasangan dan konfigurasi *pfSense* pada mesin *firewall* yang berasingan, serta integrasi kedua-dua sistem melalui *Barnyard2* dan *BASE* (*Basic Analysis and Security Engine*) sebagai antaramuka pemantauan.

**Fasa 5: Pengujian (*Testing*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pengujian sistem dijalankan menggunakan alat serangan simulasi *Nmap*, *Metasploit Framework* dan *hping3* untuk mengesahkan keupayaan sistem I Defender dalam mengesan pelbagai jenis serangan. Setiap serangan dijalankan daripada mesin penyerang (*attacker machine*) yang berasingan dalam persekitaran rangkaian makmal yang terkawal. Keputusan ujian direkodkan dan dibandingkan dengan jangkaan prestasi yang telah ditetapkan.

**Keperluan Perkakasan:**

| Bil | Perkakasan | Spesifikasi | Kuantiti |
|-----|-----------|-------------|---------|
| 1 | Server IDS | Intel Core i5, RAM 8GB, HDD 500GB | 1 unit |
| 2 | Firewall Server | Intel Core i3, RAM 4GB | 1 unit |
| 3 | Switch | 24-port Gigabit | 1 unit |
| 4 | Kabel UTP Cat6 | Panjang 20m | 5 gulung |
| 5 | Komputer Pengguna | Standard Office PC | 10 unit |

**Keperluan Perisian:**

| Bil | Perisian | Versi | Fungsi |
|-----|---------|-------|--------|
| 1 | Ubuntu Server | 22.04 LTS | Sistem Operasi Server |
| 2 | Snort IDS | 3.1.x | Pengesanan Pencerobohan |
| 3 | pfSense | 2.7.x | Firewall & Pengurusan Rangkaian |
| 4 | Wireshark | 4.x | Analisis Trafik Rangkaian |
| 5 | BASE | 1.4.5 | Antaramuka Pemantauan |

---

### KESIMPULAN

&nbsp;&nbsp;&nbsp;&nbsp;Secara keseluruhannya, Bab II ini telah menerangkan dengan terperinci metodologi yang digunakan dalam pembangunan projek I Defender. Pemilihan Model Air Terjun (*Waterfall Model*) sebagai rangka kerja pembangunan telah terbukti sesuai dengan keperluan projek ini yang mempunyai keperluan teknikal yang jelas dan berstruktur. Setiap fasa daripada perancangan sehinggalah pengujian telah dilaksanakan dengan sistematik, memastikan setiap komponen sistem berfungsi mengikut spesifikasi yang ditetapkan.

&nbsp;&nbsp;&nbsp;&nbsp;Susun atur projek yang terancang, pemilihan perkakasan dan perisian yang tepat, serta pendekatan pengujian yang komprehensif merupakan faktor utama yang menyumbang kepada kejayaan pembangunan sistem I Defender. Dengan infrastruktur yang telah dibina dan dikonfigurasi dengan teliti, sistem ini bersedia untuk menjalani fasa penilaian dan analisis hasil yang akan dibincangkan dalam bab seterusnya.

---

*[Nota Format DKM: Times New Roman Saiz 12, 1.5 Spacing, Justified, Margin Kiri 1.25" Kanan 1.0" Atas Bawah 1.0"]*

