#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

struct varray_t {
  void **memory;
  size_t allocated;
  size_t used;
  int index;
};

extern "C" {

extern varray_t *varray_init();

extern void varray_push(const varray_t *array, const void *data);

extern void *varray_get(const varray_t *array, int index);

extern int varray_length(const varray_t *array);

extern bool varray_is_empty(const varray_t *array);

extern void varray_clear(const varray_t *array);

extern const char *varnam_get_version();

extern const char *varnam_get_build();

extern const char *varnam_get_last_error(int varnamHandleID);

extern void varnam_close(int varnamHandleID);

extern const int *varnam_init(const char *vstFile, const char *learningsFile, const int *id);

extern const int *varnam_init_from_id(const char *schemeID, const int *id);

extern const int *varnam_import(int varnamHandleID, const char *filePath);

extern const int *varnam_transliterate(int varnamHandleID,
                                       int id,
                                       const char *word,
                                       varray_t **resultPointer);

} // extern "C"
