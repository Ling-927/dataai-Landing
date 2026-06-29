import React, { useEffect, useState } from "react";
import { View, Text, ScrollView, TouchableOpacity, RefreshControl, StyleSheet, Alert } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { getStats, getEvents, acknowledgeEventMobile } from "../services/api";

export default function HomeScreen() {
  const [stats, setStats] = useState<any>(null);
  const [events, setEvents] = useState<any[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    try {
      const [s, e] = await Promise.all([getStats(), getEvents(10)]);
      setStats(s);
      setEvents(e);
    } catch {}
  };

  useEffect(() => { load(); const t = setInterval(load, 15000); return () => clearInterval(t); }, []);

  const onRefresh = async () => { setRefreshing(true); await load(); setRefreshing(false); };

  return (
    <ScrollView style={styles.container} refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}>
      <View style={styles.header}>
        <Ionicons name="shield-checkmark" size={28} color="#3b82f6" />
        <Text style={styles.headerTitle}>I Defender</Text>
      </View>

      {stats && (
        <View style={styles.statsGrid}>
          <StatCard label="Jumlah" value={stats.total} color="#3b82f6" icon="car" />
          <StatCard label="Amaran" value={stats.alerts} color="#ef4444" icon="warning" />
          <StatCard label="Dibenarkan" value={stats.whitelisted} color="#22c55e" icon="checkmark-circle" />
          <StatCard label="Tidak Dikenal" value={stats.unknown} color="#f59e0b" icon="help-circle" />
        </View>
      )}

      <Text style={styles.sectionTitle}>Kejadian Terkini</Text>
      {events.map((e) => (
        <View key={e.id} style={[styles.eventCard, e.alert_triggered && styles.alertCard]}>
          <View style={styles.eventRow}>
            <Ionicons name={e.is_whitelisted ? "checkmark-circle" : e.alert_triggered ? "warning" : "car"} size={20} color={e.is_whitelisted ? "#22c55e" : e.alert_triggered ? "#ef4444" : "#6b7280"} />
            <View style={styles.eventInfo}>
              <Text style={styles.plateText}>{e.plate_number || "—"}</Text>
              <Text style={styles.eventMeta}>{e.vehicle_color} {e.vehicle_model} {e.face_name ? `• Muka: ${e.face_name}` : ""}</Text>
              <Text style={styles.timestamp}>{new Date(e.timestamp).toLocaleString("ms-MY")}</Text>
            </View>
            {e.alert_triggered && (
              <View style={styles.alertBadge}><Text style={styles.alertBadgeText}>AMARAN</Text></View>
            )}
          </View>
        </View>
      ))}
    </ScrollView>
  );
}

function StatCard({ label, value, color, icon }: any) {
  return (
    <View style={[styles.statCard, { borderLeftColor: color }]}>
      <Ionicons name={icon} size={22} color={color} />
      <Text style={[styles.statValue, { color }]}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#f8fafc" },
  header: { flexDirection: "row", alignItems: "center", gap: 10, padding: 20, paddingTop: 50, backgroundColor: "#fff", borderBottomWidth: 1, borderColor: "#e5e7eb" },
  headerTitle: { fontSize: 22, fontWeight: "700", color: "#0f172a" },
  statsGrid: { flexDirection: "row", flexWrap: "wrap", padding: 12, gap: 8 },
  statCard: { width: "47%", backgroundColor: "#fff", borderRadius: 12, padding: 14, borderLeftWidth: 4, alignItems: "center", gap: 4, shadowColor: "#000", shadowOpacity: 0.05, shadowRadius: 4, elevation: 2 },
  statValue: { fontSize: 24, fontWeight: "800" },
  statLabel: { fontSize: 11, color: "#6b7280" },
  sectionTitle: { fontSize: 16, fontWeight: "600", color: "#374151", paddingHorizontal: 16, paddingVertical: 8 },
  eventCard: { backgroundColor: "#fff", marginHorizontal: 12, marginBottom: 8, borderRadius: 12, padding: 14, shadowColor: "#000", shadowOpacity: 0.04, shadowRadius: 3, elevation: 1 },
  alertCard: { borderLeftWidth: 4, borderLeftColor: "#ef4444" },
  eventRow: { flexDirection: "row", alignItems: "center", gap: 10 },
  eventInfo: { flex: 1 },
  plateText: { fontSize: 16, fontWeight: "700", fontFamily: "monospace", color: "#1e40af" },
  eventMeta: { fontSize: 12, color: "#6b7280", marginTop: 2 },
  timestamp: { fontSize: 11, color: "#9ca3af", marginTop: 2 },
  alertBadge: { backgroundColor: "#fee2e2", paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  alertBadgeText: { color: "#dc2626", fontSize: 10, fontWeight: "700" },
});
