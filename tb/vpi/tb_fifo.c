#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>

#include "tb_fifo.h"
/*
 * Construct and return an pma fifo.
 */
tv_pma_fifo_t *tb_pma_fifo_ctor(
	void
)
{
	tv_pma_fifo_t *fifo = malloc_(tv_pma_fifo_t);
	slisth_init(&fifo->elems);
	return fifo;
}

/*
 * Delete @fifo.
 */
void tb_pma_fifo_dtor(
	tv_pma_fifo_t *fifo
)
{
	assert(fifo);
	slist *nod = 0;
	while((nod = slisth_pull(&fifo->elems))) {
		assert(nod);
		tv_pma_fifo_elem_t *elem = cntof(nod, tv_pma_fifo_elem_t, elems);
		free(elem->data);
		free(elem);
	}
	free(fifo);
}

/*
 * Construct and push an element in @fifo.
 */
void tb_pma_fifo_push(
	tv_pma_fifo_t *fifo,
	uint64_t *nv,
	ctrl_lite_s *ctrl,
	uint64_t  debug_id
)
{
	assert(fifo);
	tv_pma_fifo_elem_t *elem = malloc_(tv_pma_fifo_elem_t);
	elem->data = nv;
	elem->ctrl=ctrl;
	elem->debug_id = debug_id;
	slisth_push(&fifo->elems, &elem->elems);
	#if 0
	//#ifdef DEBUG
	printf("pma fifo push :\n");
	tb_pma_print_fifo(fifo);
	#endif
}

/*
 * If @fifo is not empty, pop an element and return it.
 * Otherwise, return 0.
 */
uint64_t *tb_pma_fifo_pop(
	tv_pma_fifo_t *fifo,
	uint64_t *debug_id,
	ctrl_lite_s **ctrl
)
{

	/* Pop. */
	assert(fifo);
	assert(debug_id);
	slist *nod = slisth_pull(&fifo->elems);
	if (!nod) return NULL;
	tv_pma_fifo_elem_t *pop = cntof(nod, tv_pma_fifo_elem_t, elems);
	assert(!pop->elems.next);

	/* Read data, delete @pop. */	
	*debug_id = pop->debug_id;
	*ctrl = pop->ctrl;
	uint64_t *ret = pop->data;
	free(pop);
	#ifdef DEBUG
	printf("pma pop, debug id : 0x");
	printf("id %016lx\n",*debug_id);
	printf("pma poped structure :\n");
	//tb_pma_print_elem(ret);	
	// print fifo
	tb_pma_print_fifo(fifo);
	#endif	

	/* Complete. */	
	return ret;

}

/*
 * Print a descriptor for all elements of @fifo.
 */
void tb_pma_print_fifo(
	tv_pma_fifo_t *fifo
)
{
	if (!fifo) return;
	printf("Fifo :\n");
	slist *nod = fifo->elems.read;
	while (nod) {
		tv_pma_fifo_elem_t *elem = cntof(nod, tv_pma_fifo_elem_t, elems);
		tb_pma_print_elem(elem);	
		nod = nod->next;
	}
	printf("\n");
}

/*
 * Print the content of a fifo element @elem
 */
void tb_pma_print_elem(
	tv_pma_fifo_elem_t *elem
){
	printf("id %016lx data %016lx\n", elem->debug_id, *elem->data);	
}



