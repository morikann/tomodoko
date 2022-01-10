import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const deletedUser = functions.region("asia-northeast1").firestore.document("/deleted_users/{documentId}").onCreate(async (snap, context) => {
  const uid = snap.data().uid;

  await admin.auth().deleteUser(uid);
  functions.logger.log("ユーザーが退会しました", context.params.documentId, uid);

  const userFollowed = admin.firestore().collection("follows").where("followed_uid", "==", uid);
  const userFollowing = admin.firestore().collection("follows").where("following_uid", "==", uid);

  await userFollowed.get().then((snap) => {
    snap.forEach((doc) => {
      doc.ref.delete();
    });
    console.log(`${snap.docs.length}件のfollowsドキュメントの削除（followed_uid = ${uid}）`);
  });

  await userFollowing.get().then((snap) => {
    snap.forEach((doc) => {
      doc.ref.delete();
    });
    console.log(`${snap.docs.length}件のfollowsドキュメントの削除（following_uid = ${uid}）`);
  });
});
