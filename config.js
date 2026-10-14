// WAAM – koppling till Supabase.
// Fyll i från Supabase → Project Settings → API.
// Anon-nyckeln är gjord för att ligga publikt; säkerheten sköts av radsäkerheten i databasen.
window.WAAM_CONFIG = {
  supabaseUrl: "https://gowzreeqjcgafewiyptf.supabase.co",
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvd3pyZWVxamNnYWZld2l5cHRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE5MTI2MTIsImV4cCI6MjEwNzQ4ODYxMn0.fVp3LbLNuC5gyxX1-vYtalq2NE4cJqIT1IgtcwByeCo",
  // Drönare och låda – byt till era riktiga värden
  drone: {
    boxTareKg: 0.6,     // lådans egen vikt tom (kg)
    maxPayloadKg: 4.5,  // drönarens maxlast inkl. låda (kg) – som Everdrone E3
    maxWindMs: 12,      // över denna vind blir det flygstopp (m/s)
    rangeKm: 10,        // räckvidd från basen (km)
    speedMs: 25,        // marschfart (m/s), 25 m/s = 90 km/h
    fleet: 3            // antal drönare för medicin (plus en för hjärtstartare)
  },
  // Drönarbasen – byt till er riktiga plats
  base: { name: "Bas: BTH campus Gräsvik, Karlskrona", lat: 56.1814, lng: 15.5906 }
};
