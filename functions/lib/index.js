"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCheckoutSession = void 0;
const functions = __importStar(require("firebase-functions"));
const express_1 = __importDefault(require("express"));
const stripe_1 = __importDefault(require("stripe"));
const admin = __importStar(require("firebase-admin"));
const cors_1 = __importDefault(require("cors"));
// Initialize Firebase Admin
admin.initializeApp();
const app = (0, express_1.default)();
// 🔹 Configure CORS correctly (accepts both localhost and site domain)
app.use((0, cors_1.default)({
    origin: true,
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
}));
// 🔹 Handle preflight OPTIONS requests
app.options("/create-checkout-session", (0, cors_1.default)());
// Body parser
app.use(express_1.default.json());
// Initialize Stripe
const stripe = new stripe_1.default("sk_test_51SPcfXCTxikVLYqMseAD91TnbMGBpw92ixiEfIxNyf3OmTkX8zflDGSeHfEqMaGGD1ly1LsUEMjZC0K8jH2iUxc800pwJ4y7ec", { apiVersion: "2025-10-29.clover" });
// 🔹 Main endpoint
app.post("/create-checkout-session", async (req, res) => {
    try {
        const { amount, currency, email } = req.body;
        if (!amount || !currency) {
            return res.status(400).json({ error: "amount and currency are required" });
        }
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ["card"],
            mode: "payment",
            line_items: [
                {
                    price_data: {
                        currency,
                        product_data: { name: "農食のオーダー" },
                        unit_amount: amount,
                    },
                    quantity: 1,
                },
            ],
            customer_email: email,
            success_url: "https://noushoku-ec.web.app/success",
            cancel_url: "https://noushoku-ec.web.app/cancel",
        });
        return res.status(200).json({ url: session.url });
    }
    catch (err) {
        console.error("Error in createCheckoutSession:", err);
        return res.status(500).json({ error: err.message || "Internal Error" });
    }
});
// 🔹 Export HTTP function (1st generation)
exports.createCheckoutSession = functions.https.onRequest(app);
//# sourceMappingURL=index.js.map