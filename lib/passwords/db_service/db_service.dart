import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:password_manager/passwords/passwords_repository/category.dart';
import 'package:password_manager/passwords/passwords_repository/passwords_repository.dart';
import 'package:password_manager/passwords/passwords_repository/service.dart';

class FirestoreService {
  static final FirestoreService _dbService = FirestoreService._();

  FirestoreService._() {
    categoriesStream.listen(
        (event) => passwordsRepository.categoryMap = {for (final Category c in event) c.id: c});
    servicesStream.listen(
        (event) => passwordsRepository.serviceMap = {for (final Service s in event) s.id: s});
  }

  factory FirestoreService() => _dbService;

  /* Properties */
  static const categoriesCollection = "categories";
  static const servicesCollection = "services";

  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: Firebase.app("pass_mngr"));
  // FirebaseFirestore get _db => FirebaseFirestore.instanceFor(app: Firebase.app("pass_mngr"));
  final PasswordsRepository passwordsRepository = PasswordsRepository();

  CollectionReference<Category> get categoriesRef =>
      _db.collection(categoriesCollection).withConverter<Category>(
            fromFirestore: (snapshot, _) =>
                Category.fromEncryptedJson(snapshot.id, snapshot.data()!),
            toFirestore: (category, _) => category.toEncryptedJson(),
          );

  CollectionReference<Service> get servicesRef =>
      _db.collection(servicesCollection).withConverter<Service>(
            fromFirestore: (snapshot, _) =>
                Service.fromEncryptedJson(snapshot.id, snapshot.data()!),
            toFirestore: (service, _) => service.toEncryptedJson(),
          );

  Stream<List<Category>> get categoriesStream =>
      categoriesRef.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Stream<List<Service>> get servicesStream =>
      servicesRef.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  /* Categories */

  Future<void> updateCategory(Category category) async {
    await categoriesRef.doc(category.id).update(category.toEncryptedJson());
  }

  /// returns the generated id of the newly created category
  Future<String> createCategory(Category category) async {
    return (await categoriesRef.add(category)).id;
  }

  Future<void> deleteCategory(String categoryId, bool keepChildServices) async {
    await categoriesRef.doc(categoryId).delete();

    QuerySnapshot snapshot =
        await _db.collection(servicesCollection).where('category', isEqualTo: categoryId).get();
    WriteBatch batch = _db.batch();

    if (keepChildServices) {
      for (final doc in snapshot.docs) {
        batch.set(doc.reference, {'category': ''}, SetOptions(merge: true));
      }
    } else {
      // delete all the services in this category
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // Commit the batch
    await batch.commit();
  }

  /* Services */

  Future<void> updateService(Service service) async {
    await servicesRef.doc(service.id).set(service);
  }

  /// returns the generated id of the newly created service
  Future<String> createService(Service service) async {
    return (await servicesRef.add(service)).id;
  }

  Future<void> deleteService(String serviceId) async {
    await servicesRef.doc(serviceId).delete();
  }
}
