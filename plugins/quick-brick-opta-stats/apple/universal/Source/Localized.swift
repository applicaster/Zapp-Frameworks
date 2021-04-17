//
//  Localized.swift
//  OptaStats
//
//  Created by Marcos Reyes - Applicaster on 4/11/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

class Localized: NSObject {
    static func getLocalizedLanguageCode() -> String {
        let deviceLocale = NSLocale.current.languageCode ?? "es"
        switch deviceLocale {
        case "en", "es", "pt":
            return deviceLocale
        default:
            return "es"
        }
    }

    // Localized strings

    fileprivate static var localizedStrings = [["es": "EQUIPO", "en": "TEAM", "pt": "EQUIPE"],
                                               ["es": "PROMEDIO POR PARTIDO", "en": "AVERAGE PER GAME", "pt": "MÉDIA POR PARTIDA"],
                                               ["es": "GOLES A FAVOR", "en": "GOALS", "pt": "GOLS A FAVOR"],
                                               ["es": "GOLES EN CONTRA", "en": "GOALS AGAINST", "pt": "GOLS CONTRA"],
                                               ["es": "POSESIÓN", "en": "POSSESSION", "pt": "POSSE DE BOLA"],
                                               ["es": "EXACTITUD DE PASE", "en": "PASS ACCURACY", "pt": "PRECISÃO DO PASSE"],
                                               ["es": "EQUIPO INICIAL", "en": "INITIAL TEAM", "pt": "EQUIPE INICIAL"],
                                               ["es": "Esta información estará disponible en breve", "en": "This information will be available soon", "pt": "Esta informação estará disponível em breve"],
                                               ["es": "JUGADOR", "en": "PLAYER", "pt": "JOGADOR"],
                                               ["es": "NOMBRE", "en": "NAME", "pt": "NOME"],
                                               ["es": "PESO", "en": "WEIGHT", "pt": "PESO"],
                                               ["es": "BIOMETRÍA", "en": "BIOMETRY", "pt": "BIOMETRIA"],
                                               ["es": "GOLES", "en": "GOALS", "pt": "GOLS"],
                                               ["es": "LUGAR DE NACIMIENTO", "en": "PLACE OF BIRTH", "pt": "LUGAR DE NASCIMENTO"],
                                               ["es": "FECHA DE NACIMIENTO", "en": "DATE OF BIRTH", "pt": "DATA DE NASCIMENTO"],
                                               ["es": "EQUIPO PROFESIONAL", "en": "PROFESSIONAL TEAM", "pt": "CLUBE"],
                                               ["es": "TORNEOS", "en": "TOURNAMENTS", "pt": "TORNEIOS"],
                                               ["es": "ALTURA", "en": "HEIGHT", "pt": "ALTURA"],
                                               ["es": "POSICIÓN", "en": "POSITION", "pt": "POSIÇÃO"],
                                               ["es": "ESTADÍSTICAS", "en": "STATISTICS", "pt": "ESTATÍSTICAS"],
                                               ["en": "COMPLETED PASSES", "pt": "PASSES COMPLETOS", "es": "PASES COMPLETADOS"],
                                               ["en": "CORNERS", "pt": "ESCANTEIOS", "es": "TIROS DE ESQUINA"],
                                               ["en": "SHOTS TO GOAL", "pt": "CHUTES A GOL", "es": "REMATES AL ARCO"],
                                               ["en": "FOULS", "pt": "FALTAS", "es": "FALTAS"],
                                               ["en": "INITIAL TEAM", "pt": "EQUIPE INICIAL", "es": "EQUIPO INICIAL"],
                                               ["en": "RESERVES", "pt": "SUBSTITUTOS", "es": "SUBSTITUTOS"],
                                               ["en": "COACH", "pt": "TREINADOR", "es": "ENTRENADOR"],
                                               ["en": "ASSISTANT", "pt": "ASSISTENTE", "es": "ASISTENTE"],
                                               ["en": "REFEREE", "pt": "ÁRBITRO", "es": "ÁRBITRO PRINCIPAL"],
                                               ["en": "ASSISTANTS", "pt": "ASSISTENTES", "es": "ASISTENTES PRINCIPALES"],
                                               ["en": "HALF TIME", "pt": "MEIO TEMPO", "es": "MEDIO TIEMPO"],
                                               ["en": "HALF", "pt": "MEIO", "es": "MEDIO"],
                                               ["en": "PLAYED", "pt": "JOGADO", "es": "JUGADO"],
                                               ["en": "PLAYING", "pt": "JOGANDO", "es": "JUGANDO"],
                                               ["en": "PENALTIES", "pt": "PÊNALTIS", "es": "PENALES"],
                                               ["en": "Goalkeeper", "pt": "Goleiro", "es": "Arquero"],
                                               ["en": "Full back", "pt": "Lateral", "es": "Lateral"],
                                               ["en": "Defender", "pt": "Zagueiro", "es": "Defensa"],
                                               ["en": "Defensive Midfielder", "pt": "Meia", "es": "Central"],
                                               ["en": "Attacking Midfielder", "pt": "Meia-atacante", "es": "Media Punta"],
                                               ["en": "Midfielder", "pt": "Meia", "es": "Medio"],
                                               ["en": "Attacker", "pt": "Atacante", "es": "Delantero"],
                                               ["en": "Substitute", "pt": "Suplente", "es": "Suplente"],
                                               ["en": "Striker", "pt": "Atacante", "es": "Delantero"],
                                               ["en": "Unknown", "pt": "Indefinido", "es": "Sin definir"]]

    static func getLocalizedString(from source: String) -> String {
        var result = source
        let lang = getLocalizedLanguageCode()

        for info in localizedStrings {
            if let englishValue = info["en"],
               let value = info[lang], englishValue == source || englishValue.lowercased() == source.lowercased() {
                result = value
                break
            }
        }

        return result
    }

    // TEAM SCREEN
    static let team: [String: Any] = ["es": "EQUIPO", "en": "TEAM", "pt": "EQUIPE"]
    static let teamCardStatsHeader: [String: Any] = ["es": "PROMEDIO POR PARTIDO", "en": "AVERAGE PER GAME", "pt": "MÉDIA POR PARTIDA"]
    static let teamGoalsMadeHeader: [String: Any] = ["es": "GOLES A FAVOR", "en": "GOALS", "pt": "GOLS A FAVOR"]
    static let teamGoalsAgainstHeader: [String: Any] = ["es": "GOLES EN CONTRA", "en": "GOALS AGAINST", "pt": "GOLS CONTRA"]
    static let teamPosessionHeader: [String: Any] = ["es": "POSESIÓN", "en": "POSSESSION", "pt": "POSSE DE BOLA"]
    static let teamPassAccuracyHeader: [String: Any] = ["es": "EXACTITUD DE PASE", "en": "PASS ACCURACY", "pt": "PRECISÃO DO PASSE"]
    static let initialTeamHeader: [String: Any] = ["es": "EQUIPO INICIAL", "en": "INITIAL TEAM", "pt": "EQUIPE INICIAL"]
    static let informationNotAvailable: [String: Any] = ["es": "Esta información estará disponible en breve", "en": "This information will be available soon", "pt": "Esta informação estará disponível em breve"]

    // PLAYER DETAILS SCREEN
    static let playerNameHeader: [String: Any] = ["es": "JUGADOR", "en": "PLAYER", "pt": "JOGADOR"]
    static let playerName: [String: Any] = ["es": "NOMBRE", "en": "NAME", "pt": "NOME"]
    static let playerWeightHeader: [String: Any] = ["es": "PESO", "en": "WEIGHT", "pt": "PESO"]
    static let playerBiometryHeader: [String: Any] = ["es": "BIOMETRÍA", "en": "BIOMETRY", "pt": "BIOMETRIA"]
    static let goalsHeader: [String: Any] = ["es": "GOLES", "en": "GOALS", "pt": "GOLS"]
    static let playerPOBHeader: [String: Any] = ["es": "LUGAR DE NACIMIENTO", "en": "PLACE OF BIRTH", "pt": "LUGAR DE NASCIMENTO"]
    static let playerDOBHeader: [String: Any] = ["es": "FECHA DE NACIMIENTO", "en": "DATE OF BIRTH", "pt": "DATA DE NASCIMENTO"]
    static let playerProfessionalTeamHeader: [String: Any] = ["es": "EQUIPO PROFESIONAL", "en": "PROFESSIONAL TEAM", "pt": "CLUBE"]
    static let playerTournamentsHeader: [String: Any] = ["es": "TORNEOS", "en": "TOURNAMENTS", "pt": "TORNEIOS"]
    static let playerHeightHeader: [String: Any] = ["es": "ALTURA", "en": "HEIGHT", "pt": "ALTURA"]
    static let playerPositionHeader: [String: Any] = ["es": "POSICIÓN", "en": "POSITION", "pt": "POSIÇÃO"]
    static let statisticsHeader: [String: Any] = ["es": "ESTADÍSTICAS", "en": "STATISTICS", "pt": "ESTATÍSTICAS"]
}
