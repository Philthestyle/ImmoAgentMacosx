import Foundation

final class DataService: DataServiceProtocol, ObservableObject {

    // MARK: - Published state

    @Published var isDemo: Bool = true

    @Published var properties: [Property] = []
    @Published var clients: [Client] = []
    @Published var mandates: [Mandate] = []
    @Published var visits: [Visit] = []
    @Published var phoneCalls: [PhoneCall] = []
    @Published var profile: UserProfile

    // MARK: - Real (user) data backing stores

    private var realProperties: [Property] = []
    private var realClients: [Client] = []
    private var realMandates: [Mandate] = []
    private var realVisits: [Visit] = []
    private var realPhoneCalls: [PhoneCall] = []

    // MARK: - Init

    init() {
        self.profile = UserProfile(
            firstName: "Sophie",
            lastName: "Martin",
            email: "sophie.martin@immoagent.be",
            phone: "+32 475 00 00 01",
            company: "ImmoAgent SPRL",
            iban: "BE68 5390 0754 7034",
            bio: "Agent immobilier agr\u{00E9}\u{00E9} IPI, sp\u{00E9}cialis\u{00E9}e dans le march\u{00E9} r\u{00E9}sidentiel bruxellois depuis 12 ans."
        )
        applyDemo()
    }

    // MARK: - Toggle

    func toggleDemo() {
        if isDemo {
            // Switching to real data
            isDemo = false
            properties = realProperties
            clients = realClients
            mandates = realMandates
            visits = realVisits
            phoneCalls = realPhoneCalls
        } else {
            // Switching to demo -- stash real data
            realProperties = properties
            realClients = clients
            realMandates = mandates
            realVisits = visits
            realPhoneCalls = phoneCalls
            isDemo = true
            applyDemo()
        }
    }

    // MARK: - CRUD helpers

    func addProperty(_ property: Property) {
        properties.append(property)
        if !isDemo { realProperties.append(property) }
    }

    func addClient(_ client: Client) {
        clients.append(client)
        if !isDemo { realClients.append(client) }
    }

    func addMandate(_ mandate: Mandate) {
        mandates.append(mandate)
        if !isDemo { realMandates.append(mandate) }
    }

    func updateMandate(_ mandate: Mandate) {
        if let index = mandates.firstIndex(where: { $0.id == mandate.id }) {
            mandates[index] = mandate
        }
        if !isDemo, let index = realMandates.firstIndex(where: { $0.id == mandate.id }) {
            realMandates[index] = mandate
        }
    }

    func updateClient(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
        }
        if !isDemo, let index = realClients.firstIndex(where: { $0.id == client.id }) {
            realClients[index] = client
        }
    }

    func updateProperty(_ property: Property) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties[index] = property
        }
        if !isDemo, let index = realProperties.firstIndex(where: { $0.id == property.id }) {
            realProperties[index] = property
        }
    }

    func addVisit(_ visit: Visit) {
        visits.append(visit)
        if !isDemo { realVisits.append(visit) }
    }

    // MARK: - Demo data loader

    private func applyDemo() {
        properties = Self.demoProperties
        clients = Self.demoClients
        mandates = Self.demoMandates
        visits = Self.demoVisits
        phoneCalls = Self.demoPhoneCalls
    }

    // MARK: - Belgian mandate document templates

    private static let belgianDocTemplates: [(name: String, description: String, category: String, required: Bool)] = [
        // 0  Identity & ownership
        ("Carte d\u{2019}identit\u{00E9} du propri\u{00E9}taire",
         "Copie recto-verso de la carte d\u{2019}identit\u{00E9} du ou des propri\u{00E9}taires",
         "identity", true),
        // 1
        ("Titre de propri\u{00E9}t\u{00E9} (acte notari\u{00E9})",
         "Acte notari\u{00E9} prouvant que vous \u{00EA}tes le propri\u{00E9}taire l\u{00E9}gal",
         "identity", true),
        // 2  Property documents
        ("Plan cadastral",
         "Plan du terrain et du b\u{00E2}timent d\u{00E9}livr\u{00E9} par l\u{2019}Administration du Cadastre",
         "property", true),
        // 3
        ("Matrice cadastrale (revenu cadastral)",
         "Document indiquant le revenu cadastral (RC) du bien",
         "property", true),
        // 4
        ("Plans du bien (architecte)",
         "Plans de construction ou r\u{00E9}novation r\u{00E9}alis\u{00E9}s par un architecte",
         "property", false),
        // 5
        ("Photos du bien",
         "Photos int\u{00E9}rieures et ext\u{00E9}rieures pour la mise en vente",
         "property", true),
        // 6  Legal - Obligatory certificates
        ("Certificat PEB",
         "Performance \u{00C9}nerg\u{00E9}tique du B\u{00E2}timent (A-G). Obligatoire d\u{00E8}s la publication de l\u{2019}annonce",
         "legal", true),
        // 7
        ("Attestation de sol",
         "Prouve l\u{2019}absence de pollution du sol. Varie selon la r\u{00E9}gion",
         "legal", true),
        // 8
        ("Contr\u{00F4}le installation \u{00E9}lectrique",
         "Proc\u{00E8}s-verbal de conformit\u{00E9} par un organisme agr\u{00E9}\u{00E9} (RGIE)",
         "legal", true),
        // 9
        ("Renseignements urbanistiques",
         "Courrier de la commune sur la situation urbanistique",
         "legal", true),
        // 10
        ("Dossier d\u{2019}Intervention Ult\u{00E9}rieure (DIU)",
         "Carnet d\u{2019}entretien obligatoire depuis 2001",
         "legal", true),
        // 11
        ("Certificat de conformit\u{00E9} urbanistique",
         "Atteste que le bien est conforme aux permis d\u{2019}urbanisme",
         "legal", false),
        // 12
        ("Attestation de non-pr\u{00E9}emption",
         "Certifie qu\u{2019}aucune autorit\u{00E9} publique ne dispose d\u{2019}un droit de pr\u{00E9}emption",
         "legal", false),
        // 13  Copropriety
        ("Acte de base + r\u{00E8}glement de copropri\u{00E9}t\u{00E9}",
         "Documents constitutifs de la copropri\u{00E9}t\u{00E9}",
         "legal", false),
        // 14
        ("PV des 3 derni\u{00E8}res AG",
         "Proc\u{00E8}s-verbaux des assembl\u{00E9}es g\u{00E9}n\u{00E9}rales des 3 derni\u{00E8}res ann\u{00E9}es",
         "legal", false),
        // 15
        ("D\u{00E9}compte des charges",
         "Relev\u{00E9} des charges de copropri\u{00E9}t\u{00E9} et du fonds de r\u{00E9}serve",
         "legal", false),
        // 16  Technical
        ("Certificat citerne \u{00E0} mazout",
         "Attestation de conformit\u{00E9} par technicien agr\u{00E9}\u{00E9}",
         "technical", false),
        // 17
        ("Attestation amiante (Flandre)",
         "Obligatoire en Flandre pour les biens construits avant 2001",
         "technical", false),
        // 18
        ("CertIBEau (Wallonie)",
         "Certificat de conformit\u{00E9} des installations d\u{2019}eau et d\u{2019}assainissement",
         "technical", false),
        // 19  Financial
        ("Pr\u{00E9}compte immobilier (dernier AER)",
         "Dernier avertissement-extrait de r\u{00F4}le du pr\u{00E9}compte immobilier",
         "financial", true),
        // 20
        ("Informations hypoth\u{00E9}caires",
         "\u{00C9}tat hypoth\u{00E9}caire du bien: hypoth\u{00E8}ques en cours",
         "financial", false),
        // 21
        ("Bail en cours",
         "Si le bien est lou\u{00E9}: copie du bail, \u{00E9}tat des lieux",
         "financial", false),
    ]

    private static func makeDocs(providedIndices: Set<Int>) -> [MandateDocument] {
        belgianDocTemplates.enumerated().map { index, tpl in
            let isProv = providedIndices.contains(index)
            let slug = tpl.name.lowercased()
                .folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr"))
                .replacingOccurrences(of: "[^a-z0-9]", with: "_", options: .regularExpression)
            return MandateDocument(
                id: "doc-\(index + 1)",
                name: tpl.name,
                description: tpl.description,
                category: tpl.category,
                required: tpl.required,
                provided: isProv,
                fileName: isProv ? "\(slug).pdf" : nil
            )
        }
    }

    // MARK: - Demo Properties (8)

    static let demoProperties: [Property] = [
        Property(
            id: "1",
            title: "Appartement lumineux - Quartier Mermoz",
            street: "Rue Jean Mermoz",
            streetNumber: "12",
            postalCode: "1050",
            city: "Ixelles",
            country: "Belgique",
            price: 285_000,
            surface: 72,
            rooms: 3,
            bedrooms: 2,
            bathrooms: 1,
            type: .apartment,
            status: .available,
            images: [],
            description: "Bel appartement traversant avec balcon sud, proche transports et commerces.",
            createdAt: "2026-02-15",
            ownerName: "Marc Janssens",
            ownerPhone: "+32 475 12 34 56",
            ownerEmail: "marc.janssens@email.be",
            listingUrl: "https://www.immoweb.be/fr/annonce/appartement/a-vendre/ixelles/1050/example1",
            mandateId: "m1"
        ),
        Property(
            id: "2",
            title: "Maison avec jardin - Uccle",
            street: "Avenue Winston Churchill",
            streetNumber: "45",
            postalCode: "1180",
            city: "Uccle",
            country: "Belgique",
            price: 520_000,
            surface: 145,
            rooms: 6,
            bedrooms: 4,
            bathrooms: 2,
            type: .house,
            status: .underOffer,
            images: [],
            description: "Grande maison familiale avec jardin arbor\u{00E9} de 400m\u{00B2}, garage double.",
            createdAt: "2026-01-20",
            ownerName: "Anne-Marie Dupont",
            ownerPhone: "+32 478 98 76 54",
            ownerEmail: "am.dupont@email.be",
            mandateId: "m2"
        ),
        Property(
            id: "3",
            title: "Studio r\u{00E9}nov\u{00E9} - Sablon",
            street: "Place du Grand Sablon",
            streetNumber: "8",
            postalCode: "1000",
            city: "Bruxelles",
            country: "Belgique",
            price: 175_000,
            surface: 28,
            rooms: 1,
            bedrooms: 1,
            bathrooms: 1,
            type: .apartment,
            status: .available,
            images: [],
            description: "Studio enti\u{00E8}rement r\u{00E9}nov\u{00E9}, id\u{00E9}al investissement locatif, emplacement premium.",
            createdAt: "2026-03-01",
            ownerName: "Philippe De Smedt",
            ownerPhone: "+32 479 11 22 33",
            ownerEmail: "p.desmedt@email.be",
            listingUrl: "https://www.immoweb.be/fr/annonce/studio/a-vendre/bruxelles/1000/example3",
            mandateId: "m3"
        ),
        Property(
            id: "4",
            title: "Villa contemporaine - Waterloo",
            street: "Chauss\u{00E9}e de Bruxelles",
            streetNumber: "3",
            postalCode: "1410",
            city: "Waterloo",
            country: "Belgique",
            price: 890_000,
            surface: 220,
            rooms: 8,
            bedrooms: 5,
            bathrooms: 3,
            type: .villa,
            status: .available,
            images: [],
            description: "Villa d'architecte avec piscine, vue panoramique.",
            createdAt: "2026-02-28",
            ownerName: "Famille Van den Berg",
            ownerPhone: "+32 476 55 66 77",
            ownerEmail: "vandenberg@email.be",
            mandateId: "m4"
        ),
        Property(
            id: "5",
            title: "T4 familial - Etterbeek",
            street: "Avenue de Tervueren",
            streetNumber: "22",
            postalCode: "1040",
            city: "Etterbeek",
            country: "Belgique",
            price: 380_000,
            surface: 95,
            rooms: 4,
            bedrooms: 3,
            bathrooms: 1,
            type: .apartment,
            status: .sold,
            images: [],
            description: "Appartement familial r\u{00E9}nov\u{00E9}, proche parc du Cinquantenaire.",
            createdAt: "2025-12-10",
            ownerName: "Luc Hermans",
            ownerPhone: "+32 477 33 44 55",
            ownerEmail: "luc.hermans@email.be",
            mandateId: "m5",
            salePrice: 365_000,
            saleCommissionPercent: 3,
            saleCommissionAmount: 10_950,
            saleDate: "2026-03-01"
        ),
        Property(
            id: "6",
            title: "Loft atypique - Saint-Gilles",
            street: "Rue de la Victoire",
            streetNumber: "15",
            postalCode: "1060",
            city: "Saint-Gilles",
            country: "Belgique",
            price: 445_000,
            surface: 110,
            rooms: 3,
            bedrooms: 2,
            bathrooms: 1,
            type: .apartment,
            status: .available,
            images: [],
            description: "Ancien atelier transform\u{00E9} en loft, plafonds 4m, terrasse 30m\u{00B2}.",
            createdAt: "2026-03-10",
            ownerName: "Isabelle Leroy",
            ownerPhone: "+32 478 22 33 44",
            ownerEmail: "i.leroy@email.be",
            listingUrl: "https://www.immoweb.be/fr/annonce/loft/a-vendre/saint-gilles/1060/example6",
            mandateId: "m6"
        ),
        Property(
            id: "7",
            title: "Terrain constructible - Lasne",
            street: "Rue de Genval",
            streetNumber: "",
            postalCode: "1380",
            city: "Lasne",
            country: "Belgique",
            price: 320_000,
            surface: 650,
            rooms: 0,
            bedrooms: 0,
            bathrooms: 0,
            type: .land,
            status: .available,
            images: [],
            description: "Terrain plat viabilis\u{00E9}, permis purg\u{00E9} pour villa 180m\u{00B2}.",
            createdAt: "2026-03-05",
            ownerName: "Jean-Pierre Claes",
            ownerPhone: "+32 479 44 55 66",
            ownerEmail: "jp.claes@email.be",
            mandateId: "m7"
        ),
        Property(
            id: "8",
            title: "Local commercial - Louise",
            street: "Avenue Louise",
            streetNumber: "55",
            postalCode: "1050",
            city: "Ixelles",
            country: "Belgique",
            price: 290_000,
            surface: 85,
            rooms: 2,
            bedrooms: 0,
            bathrooms: 1,
            type: .commercial,
            status: .available,
            images: [],
            description: "Local commercial avec vitrine, id\u{00E9}al restaurant ou boutique.",
            createdAt: "2026-02-20",
            ownerName: "SPRL Bruxelles Invest",
            ownerPhone: "+32 2 345 67 89",
            ownerEmail: "contact@bxlinvest.be",
            mandateId: "m8"
        ),
    ]

    // MARK: - Demo Clients (6)

    static let demoClients: [Client] = [
        Client(
            id: "1",
            firstName: "Marie",
            lastName: "Lecomte",
            email: "marie.lecomte@email.com",
            phone: "06 12 34 56 78",
            budget: 350_000,
            status: .visiting,
            source: .website,
            searchCriteria: "T3/T4 Bruxelles centre, balcon, proche m\u{00E9}tro",
            createdAt: "2026-02-20",
            lastContact: "2026-03-15",
            notes: "Tr\u{00E8}s motiv\u{00E9}e, recherche active depuis 3 mois.",
            propertyIds: ["1", "3"],
            interests: ["Quartiers vivants", "Proximit\u{00E9} transports", "Balcon ou terrasse", "Cuisine ouverte"]
        ),
        Client(
            id: "2",
            firstName: "Pierre",
            lastName: "Durand",
            email: "p.durand@email.com",
            phone: "06 98 76 54 32",
            budget: 600_000,
            status: .negotiating,
            source: .referral,
            searchCriteria: "Maison 5 pi\u{00E8}ces, jardin, Brabant wallon",
            createdAt: "2026-01-15",
            lastContact: "2026-03-16",
            notes: "En n\u{00E9}gociation sur la maison de Uccle. Offre \u{00E0} 495K\u{20AC}.",
            propertyIds: ["2"],
            interests: ["Jardin pour les enfants", "Garage double", "\u{00C9}coles proches", "Calme et verdure"]
        ),
        Client(
            id: "3",
            firstName: "Amira",
            lastName: "Benali",
            email: "amira.b@email.com",
            phone: "07 11 22 33 44",
            budget: 200_000,
            status: .new,
            source: .portal,
            searchCriteria: "Studio ou T2, investissement locatif",
            createdAt: "2026-03-14",
            lastContact: "2026-03-14",
            notes: "Premier achat investissement, demande informations fiscales.",
            propertyIds: ["3"],
            interests: ["Rendement locatif", "Faibles charges", "Fiscalit\u{00E9} belge", "Quartier \u{00E9}tudiant"]
        ),
        Client(
            id: "4",
            firstName: "Jean-Marc",
            lastName: "Fontaine",
            email: "jm.fontaine@email.com",
            phone: "06 55 44 33 22",
            budget: 900_000,
            status: .visiting,
            source: .social,
            searchCriteria: "Villa avec piscine, vue d\u{00E9}gag\u{00E9}e",
            createdAt: "2026-02-05",
            lastContact: "2026-03-12",
            notes: "Int\u{00E9}ress\u{00E9} par la villa de Waterloo. Visite pr\u{00E9}vue samedi.",
            propertyIds: ["4"],
            interests: ["Piscine", "Architecture contemporaine", "Vue panoramique", "Home cinema"]
        ),
        Client(
            id: "5",
            firstName: "Claire",
            lastName: "Moreau",
            email: "claire.moreau@email.com",
            phone: "06 77 88 99 00",
            budget: 450_000,
            status: .contacted,
            source: .website,
            searchCriteria: "Loft ou T3 atypique, Saint-Gilles ou Sablon",
            createdAt: "2026-03-08",
            lastContact: "2026-03-11",
            notes: "Architecte, cherche bien avec caract\u{00E8}re.",
            propertyIds: ["6", "1"],
            interests: ["Volumes atypiques", "Mat\u{00E9}riaux bruts", "Lumi\u{00E8}re naturelle", "Terrasse rooftop"]
        ),
        Client(
            id: "6",
            firstName: "Thomas",
            lastName: "Garcia",
            email: "t.garcia@email.com",
            phone: "06 33 22 11 00",
            budget: 380_000,
            status: .closed,
            source: .walkIn,
            searchCriteria: "T4 familial Etterbeek",
            createdAt: "2025-11-20",
            lastContact: "2026-03-01",
            notes: "Vente conclue le 01/03. Tr\u{00E8}s satisfait.",
            propertyIds: ["5"],
            interests: ["Parc du Cinquantenaire", "Famille", "\u{00C9}coles francophones", "Calme"]
        ),
    ]

    // MARK: - Demo Mandates (8)

    static let demoMandates: [Mandate] = [
        Mandate(
            id: "m1",
            propertyId: "1",
            propertyTitle: "Appartement lumineux - Quartier Mermoz",
            ownerName: "Marc Janssens",
            type: .exclusive,
            startDate: "2026-02-15",
            endDate: "2026-08-15",
            status: .complete,
            commissionPercent: 3,
            askingPrice: 285_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 3, 4, 6, 7, 8, 10, 12, 19])
        ),
        Mandate(
            id: "m2",
            propertyId: "2",
            propertyTitle: "Maison avec jardin - Uccle",
            ownerName: "Anne-Marie Dupont",
            type: .exclusive,
            startDate: "2026-01-20",
            endDate: "2026-07-20",
            status: .inProgress,
            commissionPercent: 3,
            askingPrice: 520_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 3, 4, 6, 8, 19])
        ),
        Mandate(
            id: "m3",
            propertyId: "3",
            propertyTitle: "Studio r\u{00E9}nov\u{00E9} - Sablon",
            ownerName: "Philippe De Smedt",
            type: .simple,
            startDate: "2026-03-01",
            endDate: "2026-09-01",
            status: .inProgress,
            commissionPercent: 2.5,
            askingPrice: 175_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 6, 7])
        ),
        Mandate(
            id: "m4",
            propertyId: "4",
            propertyTitle: "Villa contemporaine - Waterloo",
            ownerName: "Famille Van den Berg",
            type: .exclusive,
            startDate: "2026-02-28",
            endDate: "2026-08-28",
            status: .inProgress,
            commissionPercent: 3.5,
            askingPrice: 890_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 3, 4, 6, 7, 8, 10, 12])
        ),
        Mandate(
            id: "m5",
            propertyId: "5",
            propertyTitle: "T4 familial - Etterbeek",
            ownerName: "Luc Hermans",
            type: .coExclusive,
            startDate: "2025-12-10",
            endDate: "2026-06-10",
            status: .complete,
            commissionPercent: 3,
            askingPrice: 380_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14, 15, 19])
        ),
        Mandate(
            id: "m6",
            propertyId: "6",
            propertyTitle: "Loft atypique - Saint-Gilles",
            ownerName: "Isabelle Leroy",
            type: .exclusive,
            startDate: "2026-03-10",
            endDate: "2026-09-10",
            status: .draft,
            commissionPercent: 3,
            askingPrice: 445_000,
            documents: makeDocs(providedIndices: [0, 1])
        ),
        Mandate(
            id: "m7",
            propertyId: "7",
            propertyTitle: "Terrain constructible - Lasne",
            ownerName: "Jean-Pierre Claes",
            type: .simple,
            startDate: "2026-03-05",
            endDate: "2026-09-05",
            status: .inProgress,
            commissionPercent: 2.5,
            askingPrice: 320_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 3, 4, 7])
        ),
        Mandate(
            id: "m8",
            propertyId: "8",
            propertyTitle: "Local commercial - Louise",
            ownerName: "SPRL Bruxelles Invest",
            type: .exclusive,
            startDate: "2026-02-20",
            endDate: "2026-08-20",
            status: .inProgress,
            commissionPercent: 3,
            askingPrice: 290_000,
            documents: makeDocs(providedIndices: [0, 1, 2, 6, 8, 10])
        ),
    ]

    // MARK: - Demo Visits (6)

    static let demoVisits: [Visit] = [
        Visit(
            id: "1",
            propertyId: "1",
            propertyTitle: "Appartement lumineux - Quartier Mermoz",
            clientId: "1",
            clientName: "Marie Lecomte",
            date: "2026-03-18",
            time: "10:00",
            status: .scheduled,
            notes: "Premi\u{00E8}re visite, pr\u{00E9}senter le quartier.",
            agent: "Sophie Martin"
        ),
        Visit(
            id: "2",
            propertyId: "4",
            propertyTitle: "Villa contemporaine - Waterloo",
            clientId: "4",
            clientName: "Jean-Marc Fontaine",
            date: "2026-03-19",
            time: "14:30",
            status: .scheduled,
            notes: "Client tr\u{00E8}s int\u{00E9}ress\u{00E9}, pr\u{00E9}parer dossier complet.",
            agent: "Sophie Martin"
        ),
        Visit(
            id: "3",
            propertyId: "6",
            propertyTitle: "Loft atypique - Saint-Gilles",
            clientId: "5",
            clientName: "Claire Moreau",
            date: "2026-03-17",
            time: "16:00",
            status: .scheduled,
            notes: "Visite aujourd'hui. Client architecte, mettre en avant les volumes.",
            agent: "Lucas Dubois"
        ),
        Visit(
            id: "4",
            propertyId: "3",
            propertyTitle: "Studio r\u{00E9}nov\u{00E9} - Sablon",
            clientId: "3",
            clientName: "Amira Benali",
            date: "2026-03-20",
            time: "11:00",
            status: .scheduled,
            notes: "Premi\u{00E8}re visite pour investissement locatif.",
            agent: "Emma Bernard"
        ),
        Visit(
            id: "5",
            propertyId: "2",
            propertyTitle: "Maison avec jardin - Uccle",
            clientId: "2",
            clientName: "Pierre Durand",
            date: "2026-03-15",
            time: "10:30",
            status: .completed,
            notes: "Deuxi\u{00E8}me visite. Client a fait une offre \u{00E0} 495K\u{20AC}.",
            agent: "Lucas Dubois"
        ),
        Visit(
            id: "6",
            propertyId: "1",
            propertyTitle: "Appartement lumineux - Quartier Mermoz",
            clientId: "5",
            clientName: "Claire Moreau",
            date: "2026-03-14",
            time: "15:00",
            status: .completed,
            notes: "Le bien ne correspond pas aux attentes. Trop classique.",
            agent: "Sophie Martin"
        ),
    ]

    // MARK: - Demo Phone Calls (7)

    static let demoPhoneCalls: [PhoneCall] = [
        PhoneCall(id: "c1", contactName: "Marc Janssens", phone: "+32 475 12 34 56",
                  reason: "Suivi mandat - Apt Ixelles", priority: .high, time: "09:00", done: false),
        PhoneCall(id: "c2", contactName: "Anne-Marie Dupont", phone: "+32 478 98 76 54",
                  reason: "Offre re\u{00E7}ue - Maison Uccle", priority: .high, time: "10:30", done: false),
        PhoneCall(id: "c3", contactName: "Pierre Durand", phone: "+32 476 55 44 33",
                  reason: "N\u{00E9}gociation prix", priority: .high, time: "11:00", done: false),
        PhoneCall(id: "c4", contactName: "Claire Moreau", phone: "+32 477 88 99 00",
                  reason: "Visite pr\u{00E9}vue demain", priority: .medium, time: "14:00", done: false),
        PhoneCall(id: "c5", contactName: "Philippe De Smedt", phone: "+32 479 11 22 33",
                  reason: "Relance signature mandat", priority: .medium, time: nil, done: false),
        PhoneCall(id: "c6", contactName: "Jean-Marc Fontaine", phone: "+32 475 55 66 77",
                  reason: "Feedback visite Waterloo", priority: .low, time: nil, done: false),
        PhoneCall(id: "c7", contactName: "Amira Benali", phone: "+32 478 11 22 33",
                  reason: "Recherche investissement", priority: .low, time: nil, done: true),
    ]
}
