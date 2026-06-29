import React, { useEffect, useState } from "react";
import { View, Text, FlatList, TouchableOpacity, TextInput, Modal, Alert, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { getWhitelist, addPlate, deletePlate } from "../services/api";

export default function WhitelistScreen() {
  const [plates, setPlates] = useState<any[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ plate_number: "", owner_name: "", vehicle_color: "" });

  const load = async () => { try { setPlates(await getWhitelist()); } catch {} };
  useEffect(() => { load(); }, []);

  const onAdd = async () => {
    if (!form.plate_number.trim()) { Alert.alert("Ralat", "No. plat diperlukan"); return; }
    try { await addPlate(form); await load(); setShowModal(false); setForm({ plate_number: "", owner_name: "", vehicle_color: "" }); } catch (e: any) { Alert.alert("Ralat", e.message); }
  };

  const onDelete = (id: number, plate: string) => {
    Alert.alert("Padam", `Padam plat ${plate}?`, [{ text: "Batal" }, { text: "Padam", style: "destructive", onPress: async () => { await deletePlate(id); load(); } }]);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Senarai Putih Plat</Text>
        <TouchableOpacity onPress={() => setShowModal(true)} style={styles.addBtn}>
          <Ionicons name="add" size={22} color="#fff" />
        </TouchableOpacity>
      </View>

      <FlatList data={plates} keyExtractor={(i) => String(i.id)} contentContainerStyle={{ padding: 12 }}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <View style={styles.cardLeft}>
              <Text style={styles.plateText}>{item.plate_number}</Text>
              <Text style={styles.meta}>{item.owner_name || "—"} • {item.vehicle_color || "—"}</Text>
            </View>
            <TouchableOpacity onPress={() => onDelete(item.id, item.plate_number)}>
              <Ionicons name="trash-outline" size={20} color="#ef4444" />
            </TouchableOpacity>
          </View>
        )}
        ListEmptyComponent={<Text style={styles.empty}>Tiada plat dalam senarai putih</Text>}
      />

      <Modal visible={showModal} animationType="slide" transparent>
        <View style={styles.modalOverlay}>
          <View style={styles.modalBox}>
            <Text style={styles.modalTitle}>Tambah Plat</Text>
            {["plate_number", "owner_name", "vehicle_color"].map((k) => (
              <TextInput key={k} placeholder={k === "plate_number" ? "No. Plat (cth: WXY1234)" : k === "owner_name" ? "Nama Pemilik" : "Warna Kenderaan"}
                value={(form as any)[k]} onChangeText={(v) => setForm({ ...form, [k]: v })}
                style={styles.input} autoCapitalize="characters" />
            ))}
            <View style={styles.modalBtns}>
              <TouchableOpacity onPress={() => setShowModal(false)} style={styles.cancelBtn}><Text>Batal</Text></TouchableOpacity>
              <TouchableOpacity onPress={onAdd} style={styles.saveBtn}><Text style={{ color: "#fff" }}>Simpan</Text></TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#f8fafc" },
  header: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", padding: 16, paddingTop: 50, backgroundColor: "#fff", borderBottomWidth: 1, borderColor: "#e5e7eb" },
  title: { fontSize: 20, fontWeight: "700" },
  addBtn: { backgroundColor: "#3b82f6", borderRadius: 8, padding: 8 },
  card: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", backgroundColor: "#fff", borderRadius: 12, padding: 14, marginBottom: 8, shadowColor: "#000", shadowOpacity: 0.04, elevation: 1 },
  cardLeft: { flex: 1 },
  plateText: { fontSize: 17, fontWeight: "700", fontFamily: "monospace", color: "#1e40af" },
  meta: { fontSize: 12, color: "#6b7280", marginTop: 3 },
  empty: { textAlign: "center", color: "#9ca3af", marginTop: 40 },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
  modalBox: { backgroundColor: "#fff", borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20 },
  modalTitle: { fontSize: 18, fontWeight: "700", marginBottom: 16 },
  input: { borderWidth: 1, borderColor: "#e5e7eb", borderRadius: 10, paddingHorizontal: 14, paddingVertical: 10, marginBottom: 10, fontSize: 15 },
  modalBtns: { flexDirection: "row", gap: 10, marginTop: 8 },
  cancelBtn: { flex: 1, padding: 12, borderWidth: 1, borderColor: "#e5e7eb", borderRadius: 10, alignItems: "center" },
  saveBtn: { flex: 1, padding: 12, backgroundColor: "#3b82f6", borderRadius: 10, alignItems: "center" },
});
