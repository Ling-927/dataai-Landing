import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Ionicons } from "@expo/vector-icons";
import HomeScreen from "./src/screens/HomeScreen";
import WhitelistScreen from "./src/screens/WhitelistScreen";
import ScanScreen from "./src/screens/ScanScreen";
import Toast from "react-native-toast-message";

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color, size }) => {
          const icons: any = { Home: focused ? "home" : "home-outline", Whitelist: focused ? "list" : "list-outline", Scan: focused ? "scan" : "scan-outline" };
          return <Ionicons name={icons[route.name]} size={size} color={color} />;
        },
        tabBarActiveTintColor: "#3b82f6",
        tabBarInactiveTintColor: "#6b7280",
      })}>
        <Tab.Screen name="Home" component={HomeScreen} options={{ tabBarLabel: "Dashboard" }} />
        <Tab.Screen name="Whitelist" component={WhitelistScreen} options={{ tabBarLabel: "Senarai Putih" }} />
        <Tab.Screen name="Scan" component={ScanScreen} options={{ tabBarLabel: "Imbas" }} />
      </Tab.Navigator>
      <Toast />
    </NavigationContainer>
  );
}
