import React, { useState } from "react";
import { View, Text, TouchableOpacity, Image, ScrollView, StyleSheet, Alert } from "react-native";
import * as ImagePicker from "expo-image-picker";
import { Ionicons } from "@expo/vector-icons";
import { analyzeImageMobile } from "../services/api";

export default function ScanScreen() {
  const [imageUri, setImageUri] = useState<string | null>(null);
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const pickImage = async () => {
    const r = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ImagePicker.MediaTypeOptions.Images, quality: 0.8 });
    if (!r.canceled) { setImageUri(r.assets[0].uri); setResult(null); }
  };

  const takePhoto = async () => {
    const r = await ImagePicker.launchCameraAsync({ quality: 0.8 });
    if (!r.canceled) { setImageUri(r.assets[0].uri); setResult(null); }
  };

  const analyze = async () => {
    if (!imageUri) return;
    setLoading(true);
    try {
      const res = await analyzeImageMobile(imageUri);
      setResult(res);
    } catch (e: any) {
      Alert.alert("Ralat", e.message || "Analisis gagal");
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}><Text style={styles.title}>Imbas Kenderaan</Text></View>

      <View style={styles.btnRow}>
        <TouchableOpacity onPress={takePhoto} style={styles.btnBlue}>
          <Ionicons name="camera" size={20} color="#fff" />
          <Text style={styles.btnText}>Kamera</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={pickImage} style={styles.btnGray}>
          <Ionicons name="image" size={20} color="#374151" />
          <Text style={[styles.btnText, { color: "#374151" }]}>Galeri</Text>
        </TouchableOpacity>
      </View>

      {imageUri && (
        <View style={styles.imageBox}>
          <Image source={{ uri: imageUri }} style={styles.image} resizeMode="contain" />
          <TouchableOpacity onPress={analyze} disabled={loading} style={[styles.btnBlue, styles.analyzeBtn]}>
            <Ionicons name="scan" size={20} color="#fff" />
            <Text style={styles.btnText}>{loading ? "Menganalisis..." : "Analisis AI"}</Text>
          </TouchableOpacity>
        </View>
      )}

      {result && (
        <View style={styles.resultBox}>
          <Text style={styles.resultTitle}>Keputusan</Text>
          <ResultRow label="No. Plat" value={result.plate_number} />
          <ResultRow label="Keyakinan" value={result.plate_confidence ? `${(result.plate_confidence * 100).toFixed(1)}%` : "—"} />
          <ResultRow label="Jenis" value={result.vehicle_model} />
          <ResultRow label="Warna" value={result.vehicle_color} />
          <ResultRow label="Muka" value={result.face_name || (result.face_recognized ? "Ya" : "Tidak")} />
          <View style={[styles.statusBadge, { backgroundColor: result.is_whitelisted ? "#dcfce7" : result.alert_triggered ? "#fee2e2" : "#f3f4f6" }]}>
            <Text style={{ color: result.is_whitelisted ? "#15803d" : result.alert_triggered ? "#dc2626" : "#374151", fontWeight: "700", textAlign: "center" }}>
              {result.is_whitelisted ? "✅ Kenderaan Dibenarkan" : result.alert_triggered ? "🚨 KENDERAAN TIDAK DIBENARKAN" : "⚠️ Tidak Dikenal"}
            </Text>
          </View>
        </View>
      )}
    </ScrollView>
  );
}

function ResultRow({ label, value }: { label: string; value: any }) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Text style={styles.rowValue}>{value || "—"}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#f8fafc" },
  header: { padding: 16, paddingTop: 50, backgroundColor: "#fff", borderBottomWidth: 1, borderColor: "#e5e7eb" },
  title: { fontSize: 20, fontWeight: "700" },
  btnRow: { flexDirection: "row", gap: 10, padding: 16 },
  btnBlue: { flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8, backgroundColor: "#3b82f6", padding: 12, borderRadius: 10 },
  btnGray: { flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8, backgroundColor: "#fff", padding: 12, borderRadius: 10, borderWidth: 1, borderColor: "#e5e7eb" },
  btnText: { color: "#fff", fontWeight: "600" },
  imageBox: { marginHorizontal: 16, borderRadius: 12, overflow: "hidden", backgroundColor: "#000" },
  image: { width: "100%", height: 250 },
  analyzeBtn: { margin: 12, borderRadius: 10, flex: 0 },
  resultBox: { margin: 16, backgroundColor: "#fff", borderRadius: 12, padding: 16, shadowColor: "#000", shadowOpacity: 0.06, elevation: 2 },
  resultTitle: { fontSize: 16, fontWeight: "700", marginBottom: 12 },
  row: { flexDirection: "row", justifyContent: "space-between", paddingVertical: 8, borderBottomWidth: 1, borderColor: "#f3f4f6" },
  rowLabel: { color: "#6b7280", fontSize: 13 },
  rowValue: { fontWeight: "600", fontSize: 13 },
  statusBadge: { marginTop: 12, padding: 12, borderRadius: 10 },
});
