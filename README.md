# Airbnb Veri Analizi: Yüksek Performanslı İlanlar

Airbnb `calendar` ve `listing` verileriyle, yüksek performanslı ilanların başarısını BigQuery ve Looker Studio ile analiz eden proje.

## Amaç
Gelire göre en üst %10'luk ilanların diğerlerinden neyle ayrıştığını (fiyat, doluluk, puan) açıklamak.

## Veri ve yöntem
- **Veri:** Airbnb `calendar` ve `listing` tabloları (Google Sheets'ten BigQuery'ye aktarıldı).
- **Temizleme ve zenginleştirme:** BigQuery SQL ile (`sql/` klasörü).
- **Görselleştirme:** Looker Studio.

| Sıra | Dosya | Ne yapar |
|---|---|---|
| 1 | `01_joined_dataset.sql` | calendar ve listing tablolarını birleştirir |
| 2 | `02_listing_performance.sql` | İlan bazında gelir, doluluk, segment ve puan bandı |
| 3 | `03_daily_performance.sql` | Günlük ilan tablosu (dashboard kaynağı) |
| 4 | `04_null_checks.sql` | Eksik veri kontrolü |

**Segment tanımı:** İlanlar toplam tahmini gelire göre onluk dilimlere ayrıldı. İlk dilim Yüksek Performans, 2-5 Orta, kalanı Düşük.

## KPI tanımları
| KPI | Formül | Anlamı |
|---|---|---|
| Occupancy Rate | `SUM(booked_days) / SUM(total_days)` | Doluluk oranı |
| ADR | `SUM(booked_revenue) / SUM(booked_days)` | Ortalama günlük fiyat |
| RevPAR | `SUM(booked_revenue) / SUM(total_days)` | Müsait gün başına gelir |

## Bulgular
- İlanların %10'u (50 ilan) gelirin %29'unu üretiyor.
- Yüksek ve Orta segmentin doluluğu aynı (%86); fark fiyattan geliyor (ADR 380 ve 148, yaklaşık 2.6 kat).
- Düşük segment hem doluluk (%65) hem fiyatta (ADR 87) geride.
- Ortalama puan segmentler arasında neredeyse aynı (4.66-4.68), yani fark puanla açıklanmıyor.

## Dashboard
- [Looker Studio raporu](https://datastudio.google.com/s/oim4HRfq0v0)
- [AIRBNB_BI_Report-Dashboard.pdf](https://github.com/user-attachments/files/35375881/AIRBNB_BI_Report-Dashboard.pdf)


![Dashboard Sayfa 1](dashboard/sayfa1.png)

## Sınırlamalar
- `available = false` günler gerçek rezervasyon değil, takvim kapatma da olabilir; doluluk "tahmini"dir.
- `host_id` yerine `listing_id` kullanıldı; analiz ev sahibi değil ilan bazındadır.
- Segmentler gelire göre tanımlandığı için "yüksek gelirliler yüksek gelirli" kısmen döngüsel; asıl bulgu farkın fiyattan gelmesi.
