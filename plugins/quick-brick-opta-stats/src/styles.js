import { StyleSheet } from "react-native";


export const styles = StyleSheet.create({
    container: {
      flex: 1,
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: "transparent",
    },
  });
  
export const stylesError = StyleSheet.create({
    container: {
        flex: 1,
        borderRadius: 5,
      alignItems: "center",
      justifyContent: "center",
      color: "white",
        backgroundColor: "rgba(255,255 ,255,1)",
    },
    alert: {
        fontSize: 50,
    },
    button: {
        color: "rgba(255,255,255,1)",
        backgroundColor: "rgba(220, 15, 15, 0.8)",
        height: 70,
        width: 180,
        borderRadius: 35,
        marginVertical: 40,
        alignItems: "center",
        justifyContent: "center",
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.23,
        shadowRadius: 2.62,
        
        elevation: 4,
    },
    buttonText: {
        color: "rgba(255,255,255,1)",
        fontSize: 20,
    },
    errorMessage: {},
    message: {
        fontWeight: "bold",
        fontSize: 20,
        marginVertical: 10,
    }
  });
  