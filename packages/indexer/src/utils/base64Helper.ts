export const decodeBase64ToJson = <T>(uri: string) => {
  const base64 = uri.split(",")[1]; // Remove the "data:application/json;base64," part
  const jsonStr = atob(base64); // Decode base64 to string
  return JSON.parse(jsonStr) as T; // Parse JSON
};
